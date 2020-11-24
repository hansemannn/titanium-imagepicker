# Titanium - Multi-Image picker module

This module uses the [Matisse SDK](https://github.com/zhihu/Matisse) on Android and [YPImagePicker](https://github.com/Yummypets/YPImagePicker) on iOS.

## Important Note

This started as a parity effort via [@prashantsaini1/titanium-imagepicker](https://github.com/prashantsaini1/titanium-imagepicker) but as we decided to use different libraries than before (lately by using `Matisse` instead of an own library).

## Requirements & Installation

- Android: Titanium 7.0.0+
- iOS: Titanium 9.2.0+

```
<module platform="android">ti.imagepicker</module>
<module platform="iphone">ti.imagepicker</module>
```

# Methods

### openGallery()

- Opens the inbuilt gallery with a 3x3 default grid-view.
- Takes following arguments in a single dictionary object. (All arguments are optional though)

| Argument                     | Description                                                                                | Default Value                          | Platform     |
| ---------------------------- | ------------------------------------------------------------------------------------------ | -------------------------------------- | ------------ |
| String **doneButtonTitle**   | Title of the OK button which calls the callback method                                     | Done                                   | Android, iOS |
| String **nextButtonTitle**   | Title of the "Next" button                                                                 | Next                                   | iOS          |
| String **cancelButtonTitle** | Title of the "Cancel" button                                                               | Cancel                                 | iOS          |
| String **cameraTitle**       | Title of the "Photo" button                                                                | Photo                                  | iOS          |
| String **libraryTitle**      | Title of the "Library" button                                                              | Library                                | iOS          |
| String **albumsTitle**       | Title of the "Albums" button                                                               | Albums                                 | iOS          |
| Bool **square**              | Use square images only                                                                     | `false`                                | iOS          |
| int **columnCount**          | Number of grid-view columns to show in gallery                                             | 3 (2 to 5 on Android, no limit on iOS) | , iOS        |
| int **maxImageSelection**    | Maximum number of images to select. Can be used for single image selection by passing as 1 | No limit                               | Android      |
| function **callback**        | Callback method to get results into. See below example for its usage                       | none                                   | Android, iOS |
| skipSelectionsGallery        | skip the selections gallery                                                                | `false`                                | iOS          |
| showsPhotoFilters            | shows photo filters                                                                        | `false`                                | iOS          |
| shouldSaveNewPicturesToAlbum | save new pictures to album                                                                 | `false`                                | iOS          |
| defaultMultipleSelection     | default multiple selection                                                                 | `false`                                | iOS          |
| enablePhoto                  | enable or disable photo                                                                    | `false`                                | iOS          |
| minNumberOfItems             | min number of photos                                                                  | 1                                      | iOS          |
| mode             | image selection mode (IMAGE_PICKER_MODE_ALL, IMAGE_PICKER_MODE_PHOTO, IMAGE_PICKER_MODE_LIBRARY)                                                                 | IMAGE_PICKER_MODE_ALL                                      | iOS          |

```javascript
import ImagePicker from 'ti.imagepicker';

ImagePicker.openGallery({
  callback: function(e) {
    if (e.success) {
      var allImages = e.images;
    } else if (e.cancel) {
      // gallery result cancelled
    } else {
      alert(e.message);
    }
  }
});
```

# Compile the iOS module

go INTO ios folder and install YPImagePicker

```
carthage update
```

build the module

```
ti build -p ios --build-only
```

## LICENSE

MIT
