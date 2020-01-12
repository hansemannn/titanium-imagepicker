package ti.imagepicker;

import java.io.FileInputStream;

import android.content.ContentResolver;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.os.ParcelFileDescriptor;
import android.provider.MediaStore;
import android.media.ExifInterface;
import android.webkit.MimeTypeMap;


public class Utils {
	public static int getOrientation(ContentResolver contentResolver, Uri uri) {
        int orientation = -1;
        String fileExtension = getMimeType(contentResolver, uri);

        // go through the exif-data only for the JPG/JPEG files as described in below link
        // FIXME: https://github.com/bumptech/glide/issues/3851
        if (fileExtension.equalsIgnoreCase("jpg") || fileExtension.equalsIgnoreCase("jpeg")) {
            try {
                ExifInterface exif;

                if (Build.VERSION.SDK_INT >= 29) {
                    ParcelFileDescriptor parcelFileDescriptor = contentResolver.openFileDescriptor(uri, "r", null);
                    FileInputStream fileInputStream = new FileInputStream(parcelFileDescriptor.getFileDescriptor());
                    exif = new ExifInterface(fileInputStream);
                    fileInputStream.close();
                    
                } else {
                    exif = new ExifInterface( getUriPath(contentResolver, uri) );
                }

                // returns undefined-orientation (0) as default
                orientation = exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_UNDEFINED);

            } catch (Exception exc) {
            	exc.printStackTrace();
            }
        }

        return orientation;
    }

    public static String getMimeType(ContentResolver contentResolver, Uri uri) {
        String extension;

        // check uri format to avoid null
        if (uri.getScheme().equals(ContentResolver.SCHEME_CONTENT)) {
            // if scheme is a content
            final MimeTypeMap mime = MimeTypeMap.getSingleton();
            extension = mime.getExtensionFromMimeType(contentResolver.getType(uri));
        } else {
            // if scheme is a File
            // this will replace white spaces with %20 and also other special characters. This will avoid returning null values on file name with spaces and special characters.
            extension = MimeTypeMap.getFileExtensionFromUrl(uri.toString());

        }

        return extension;
    }

    public static String getUriPath(ContentResolver resolver, Uri uri) {
        if (uri == null) {
            return null;
        }

        if (uri.getScheme().equals(ContentResolver.SCHEME_CONTENT)) {
            Cursor cursor = null;
            try {
                cursor = resolver.query(uri, new String[]{MediaStore.Images.ImageColumns.DATA},
                        null, null, null);
                if (cursor == null || !cursor.moveToFirst()) {
                    return null;
                }
                return cursor.getString(cursor.getColumnIndex(MediaStore.Images.ImageColumns.DATA));
            } finally {
                if (cursor != null) {
                    cursor.close();
                }
            }
        }
        return uri.getPath();
    }
}
