package ti.imagepicker;

import org.appcelerator.kroll.common.Log;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

import com.zhihu.matisse.Matisse;
import com.zhihu.matisse.MimeType;
import com.zhihu.matisse.engine.impl.PicassoEngine;
import com.zhihu.matisse.internal.entity.CaptureStrategy;

public class TiMatisseActivity extends Activity {
	
	public static final String PROPERTY_MAX_IMAGE_SELECTION = "maxImageSelection";
		
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        Intent i = getIntent();
        Bundle extras = i.getExtras();
        
        int maxImageSelection = extras.getInt(PROPERTY_MAX_IMAGE_SELECTION);
        
        Matisse.from(this)
            .choose(MimeType.ofImage())
            .capture(true)
            .captureStrategy(new CaptureStrategy(true, "io.lambus.app.provider"))
            .countable(true)
            .maxSelectable(maxImageSelection)
            .imageEngine(new PicassoEngine())
            .forResult(1337);
    }
    
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        // Just pass on this result upstream
        setResult(resultCode, data);
        finish();
    }
}