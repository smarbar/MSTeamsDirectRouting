Deploy Module {
  By PSGalleryModule {
      FromSource Build\MSTeamsDirectRouting
      To PSGallery
      WithOptions @{
        #test
        ApiKey = $ENV:GALLERY_API_KEY
      }
  }
}