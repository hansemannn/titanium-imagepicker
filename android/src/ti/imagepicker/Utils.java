package ti.imagepicker;

import java.io.File;
import java.io.FileInputStream;
import java.io.InputStream;

import android.support.media.ExifInterface;


public class Utils {
	public static int getOrientation(File file) {
		int orientation = -1;
		
		try {
			InputStream stream = new FileInputStream(file);
			
			if (stream != null) {
				ExifInterface exifInterface = new ExifInterface(stream);
				orientation = exifInterface.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL);
				
				// close the stream to release its resources
				stream.close();
			}
		} catch (Exception ex) {
			ex.printStackTrace();
		}
		
		return orientation;
	}
}
