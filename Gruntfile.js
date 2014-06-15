module.exports = function(grunt) {
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    
    less: {
      development: {
        options: {
          compress: true,
          yuicompress: true,
          optimization: 2
        },
        files: {
          "public/css/app.css": "app/assets/less/app.less" 
        }
      } 
    },

    watch: {
      styles: {
        files: ['app/assets/less/app.less'],
        tasks: ['less'],
        options: {
          nospawn: true 
        }
      } 
    }
    

  });

  grunt.loadNpmTasks('grunt-contrib-less');
  grunt.loadNpmTasks('grunt-contrib-watch');

  grunt.registerTask('default', ['watch']);
}
