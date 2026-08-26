import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus = application
//= require rails-ujs
//= require turbolinks
//= require_tree .
document.addEventListener("turbolinks:load", function () {
    tinymce.init({
        selector: 'textarea.tinymce',
        plugins: 'image',
        toolbar: 'undo redo | formatselect | bold italic | alignleft aligncenter alignright | bullist numlist outdent indent | image',
        image_title: true,
        automatic_uploads: true,
        images_upload_url: '/images/upload', // Ruta para cargar imágenes
        images_upload_handler: function (blobInfo, success, failure) {
            // Lógica para subir imágenes al servidor
        }
    });
});

export { application }
