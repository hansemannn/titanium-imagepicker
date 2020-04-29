//
//  TiImagepickerModule.swift
//  titanium-imagepicker
//
//  Created by Hans Knöchel
//  Copyright (c) 2019 Hans Knöchel. All rights reserved.
//

import UIKit
import TitaniumKit
import YPImagePicker

@objc(TiImagepickerModule)
class TiImagepickerModule: TiModule {

  public let testProperty: String = "Hello World"

  func moduleGUID() -> String {
    return "8477e94d-ea5f-4fe6-8f6a-1e6bacbda2d7"
  }

  override func moduleId() -> String! {
    return "ti.imagepicker"
  }

  override func startup() {
    super.startup()
    debugPrint("[DEBUG] \(self) loaded")
  }

  @objc(openGallery:)
  func openGallery(arguments: Array<Any>?) {
    guard let arguments = arguments, let options = arguments[0] as? [String: Any] else { return }
    guard let callback: KrollCallback = options["callback"] as? KrollCallback else { return }

    let forceSquare = options["forceSquare"] as? Bool ?? false

    let skipSelectionsGallery = options["skipSelectionsGallery"] as? Bool ?? true
    let showsPhotoFilters = options["showsPhotoFilters"] as? Bool ?? false
    let shouldSaveNewPicturesToAlbum = options["shouldSaveNewPicturesToAlbum"] as? Bool ?? false
    let defaultMultipleSelection = options["defaultMultipleSelection"] as? Bool ?? true
    let enablePhoto = options["enablePhoto"] as? Bool ?? false

    var config = YPImagePickerConfiguration()

    // Some hardcoded values that may become configurable in the future
    config.showsPhotoFilters = showsPhotoFilters
    config.startOnScreen = .library
    if enablePhoto != false {
      config.screens = [.library, .photo]
    }else{
      config.screens = [.library]
    }
    config.shouldSaveNewPicturesToAlbum = shouldSaveNewPicturesToAlbum
    config.onlySquareImagesFromCamera = forceSquare
    config.library.onlySquare = forceSquare
    config.showsCrop = .none
    config.targetImageSize = YPImageSize.original

    config.library.skipSelectionsGallery = skipSelectionsGallery
    config.library.defaultMultipleSelection = defaultMultipleSelection

    //config.library.preselectedItems = nil

    // General (optional) config
    config.library.numberOfItemsInRow = options["columnCount"] as? Int ?? 3

    if options["tintColor"] != nil {
      config.colors.tintColor = TiUtils.colorValue(options["tintColor"])!.color
    }

    if options["maxImageSelection"] != nil {
      config.library.maxNumberOfItems = options["maxImageSelection"] as? Int ?? 99
    }

    if options["minNumberOfItems"] != nil {
      config.library.minNumberOfItems = options["minNumberOfItems"] as? Int ?? 1
    }

    if options["doneButtonTitle"] != nil {
      config.wordings.done = options["doneButtonTitle"] as! String
    }

    if options["cancelButtonTitle"] != nil {
      config.wordings.cancel = options["cancelButtonTitle"] as! String
    }

    if options["nextButtonTitle"] != nil {
      config.wordings.next = options["nextButtonTitle"] as! String
    }

    if options["cameraTitle"] != nil {
      config.wordings.cameraTitle = options["cameraTitle"] as! String
    }

    if options["libraryTitle"] != nil {
      config.wordings.libraryTitle = options["libraryTitle"] as! String
    }

    if options["albumsTitle"] != nil {
      config.wordings.albumsTitle = options["albumsTitle"] as! String
    }

    if options["capturePhotoImage"] != nil {
      config.icons.capturePhotoImage = TiUtils.image(options["capturePhotoImage"], proxy: self)
    }

    if options["multipleSelectionOnIcon"] != nil {
      config.icons.multipleSelectionOnIcon = TiUtils.image(options["multipleSelectionOnIcon"], proxy: self)
    }

    if options["multipleSelectionOffIcon"] != nil {
      config.icons.multipleSelectionOffIcon = TiUtils.image(options["multipleSelectionOffIcon"], proxy: self)
    }

    let picker = YPImagePicker(configuration: config)

    picker.didFinishPicking { [unowned picker] items, cancelled in
      if cancelled {
        callback.call([["success": false, "cancel": true, "images": []]], thisObject: self)
        picker.dismiss(animated: true, completion: nil)
        return
      }

      var images: [TiBlob] = []

      for item in items {
        switch item {
        case .photo(let photo):
          images.append(self.blob(from: photo.image))
        case .video(_):
          print("[WARN] Videos are not handled so far")
        }
      }

      callback.call([["images": images, "success": true]], thisObject: self)
      picker.dismiss(animated: true, completion: nil)
    }

    guard let controller = TiApp.controller(), let topPresentedController = controller.topPresentedController() else {
      print("[WARN] No window opened. Ignoring gallery call …")
      return
    }

    topPresentedController.present(picker, animated: true, completion: nil)
  }

  private func blob(from image: UIImage) -> TiBlob {
    return TiBlob(image: image)
  }
}
