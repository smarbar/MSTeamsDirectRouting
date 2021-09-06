Deploy Module {
  By PSGalleryModule {
      FromSource Build\MSTeamsDirectRouting
      To PSGallery
      WithOptions @{
          ApiKey = $ENV:PSGalleryKey
      }
  }
}