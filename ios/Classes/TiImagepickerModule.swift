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
import Photos
import PhotosUI

enum TiImagePickerMode: Int {
  case library = 0
  case photo = 1
  case all = 2
}

@objc(TiImagepickerModule)
class TiImagepickerModule: TiModule {
  
  private var _iOS14Callback: KrollCallback?
  
  @objc(IMAGE_PICKER_MODE_LIBRARY)
  let IMAGE_PICKER_MODE_LIBRARY = TiImagePickerMode.library.rawValue
  
  @objc(IMAGE_PICKER_MODE_PHOTO)
  let IMAGE_PICKER_MODE_PHOTO = TiImagePickerMode.photo.rawValue
  
  @objc(IMAGE_PICKER_MODE_ALL)
  let IMAGE_PICKER_MODE_ALL = TiImagePickerMode.all.rawValue

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
    let mode = TiImagePickerMode(rawValue: options["mode"] as? Int ?? TiImagePickerMode.all.rawValue)

    if #available(iOS 14.0, *), mode != .photo {
      openiOS14Gallery(options: options)
      return
    }
    
    guard let callback: KrollCallback = options["callback"] as? KrollCallback else { return }

    let square = options["square"] as? Bool ?? false

    let skipSelectionsGallery = options["skipSelectionsGallery"] as? Bool ?? true
    let showsPhotoFilters = options["showsPhotoFilters"] as? Bool ?? false
    let shouldSaveNewPicturesToAlbum = options["shouldSaveNewPicturesToAlbum"] as? Bool ?? false
    let defaultMultipleSelection = options["defaultMultipleSelection"] as? Bool ?? true

    var config = YPImagePickerConfiguration()

    // Some hardcoded values that may become configurable in the future
    config.showsPhotoFilters = showsPhotoFilters
    config.shouldSaveNewPicturesToAlbum = shouldSaveNewPicturesToAlbum

    if mode == TiImagePickerMode.all {
      config.startOnScreen = .library
      config.screens = [.library, .photo]
    } else if mode == TiImagePickerMode.library {
      config.startOnScreen = .library
      config.screens = [.library]
    } else if mode == TiImagePickerMode.photo {
       config.startOnScreen = .photo
       config.screens = [.photo]
    }

    config.shouldSaveNewPicturesToAlbum = false
    config.onlySquareImagesFromCamera = square
    config.library.onlySquare = square
    config.library.isSquareByDefault = square
    config.showsCrop = .none

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

    picker.modalPresentationStyle = .fullScreen
    topPresentedController.present(picker, animated: true, completion: nil)
  }

  @available(iOS 14.0, *)
  private func openiOS14Gallery(options: [String: Any]) {
    guard let callback: KrollCallback = options["callback"] as? KrollCallback else { return }
    let maxImageSelection = options["maxImageSelection"] as? Int ?? 25
    
    var configuration = PHPickerConfiguration()
    configuration.filter = .images
    configuration.selectionLimit = maxImageSelection

    _iOS14Callback = callback

    guard let controller = TiApp.controller(), let topPresentedController = controller.topPresentedController() else {
      print("[WARN] No window opened. Ignoring gallery call …")
      return
    }
    
    let picker = PHPickerViewController(configuration: configuration)
    picker.delegate = self
    topPresentedController.present(picker, animated: true)
  }
  
  private func blob(from image: UIImage) -> TiBlob {
    return TiBlob(image: image)
  }
  
  deinit {
    _iOS14Callback = nil
  }
}

// MARK: PHPickerViewControllerDelegate

@available(iOS 14.0, *)
extension TiImagepickerModule : PHPickerViewControllerDelegate {

  func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    var images: [TiBlob] = []
    let group = DispatchGroup()
    
    guard let callback = _iOS14Callback else { return }

    for result in results {
      group.enter()
      let itemProvider = result.itemProvider

      // Get the reference of itemProvider from results
      if itemProvider.canLoadObject(ofClass: UIImage.self) {
        itemProvider.loadObject(ofClass: UIImage.self) { [weak self]  image, error in
          guard let self = self else { return }
          guard error == nil else {
            callback.call([["success": false, "images": [], "error": error?.localizedDescription ?? "Eror"]], thisObject: self)
            group.leave()
            return
          }
          if let image = image as? UIImage {
            images.append(self.blob(from: image))
            group.leave()
          }
        }
      }
    }

    group.notify(queue: .global(qos: .background)) { [weak self] in
      guard let self = self else { return }
      TiThreadPerformOnMainThread({
        picker.dismiss(animated: true) {
          if let callback = self._iOS14Callback {
            callback.call([["images": images, "success": true]], thisObject: self)
            self._iOS14Callback = nil
          }
        }
      }, false)
    }
  }
}

