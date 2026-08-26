ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

# Rails fixtures are ActiveRecord-only, and this app runs on Mongoid, so
# `fixtures :all` raised NoMethodError and no test could ever load. This is a
# minimal stand-in: it reads the same test/fixtures/*.yml files and exposes the
# same users(:one) / notes(:one) accessors, backed by Mongoid documents.
#
# Documents are rebuilt per test because the teardown purges the database.
module MongoidFixtures
  extend ActiveSupport::Concern

  FIXTURE_PATH = Rails.root.join("test", "fixtures")

  # sender/receiver/share are plain BSON ids on the model, not relations, so
  # they are resolved by hand rather than assigned as associations.
  ID_REFERENCES = { "sender" => :users, "receiver" => :users, "share" => :notes }.freeze

  included do
    setup :load_mongoid_fixtures
  end

  def users(label)
    fixture(:users, label)
  end

  def notes(label)
    fixture(:notes, label)
  end

  def collections(label)
    fixture(:collections, label)
  end

  def notifications(label)
    fixture(:notifications, label)
  end

  private

  def fixture(kind, label)
    @fixtures.fetch(kind).fetch(label.to_sym) do
      raise ArgumentError, "No #{kind} fixture named #{label.inspect}"
    end
  end

  def load_mongoid_fixtures
    @fixtures = { users: {}, notes: {}, collections: {}, notifications: {} }

    read_fixture_file("users").each do |label, attrs|
      @fixtures[:users][label] = User.create!(attrs)
    end

    %w[notes collections].each do |kind|
      read_fixture_file(kind).each do |label, attrs|
        owner = @fixtures[:users].fetch(attrs.delete("user").to_sym)
        klass = kind.classify.constantize
        @fixtures[kind.to_sym][label] = klass.create!(attrs.merge(user: owner))
      end
    end

    read_fixture_file("notifications").each do |label, attrs|
      @fixtures[:notifications][label] = build_notification(attrs)
    end
  end

  def build_notification(attrs)
    ID_REFERENCES.each do |key, kind|
      label = attrs.delete(key)
      attrs["#{key}_id"] = fixture(kind, label).id if label
    end

    owner = @fixtures[:users].fetch(attrs.delete("user").to_sym)
    Notification.create!(attrs.merge(user: owner))
  end

  def read_fixture_file(name)
    raw = ERB.new(File.read(FIXTURE_PATH.join("#{name}.yml"))).result
    (YAML.safe_load(raw, aliases: true) || {}).transform_keys(&:to_sym)
  end
end

class ActiveSupport::TestCase
  # Not parallelised: the teardown below purges the whole database, so parallel
  # workers sharing one MongoDB would wipe each other's fixtures mid-test.
  include MongoidFixtures

  teardown do
    Mongoid.purge! if defined?(Mongoid)
  end
end
