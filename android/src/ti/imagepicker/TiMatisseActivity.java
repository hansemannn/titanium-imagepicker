package ti.imagepicker;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

import com.zhihu.matisse.Matisse;
import com.zhihu.matisse.MimeType;
import com.zhihu.matisse.engine.impl.GlideEngine;
import com.zhihu.matisse.internal.entity.CaptureStrategy;

import org.appcelerator.kroll.common.Log;


public class TiMatisseActivity extends Activity {		
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        Intent i = getIntent();
        Bundle extras = i.getExtras();
        
        int maxImageSelection = extras.getInt(Defaults.PROPERTY_MAX_IMAGE_SELECTION);
        String provider = getApplicationContext().getPackageName() + ".provider";
        
        Matisse.from(this)
            .choose(MimeType.ofImage())
            .capture(true)
            .captureStrategy(new CaptureStrategy(true, provider))
            .countable(true)
            .maxSelectable(maxImageSelection)
            .thumbnailScale(0.80f)
            .imageEngine(new GlideEngine())
            .showSingleMediaType(true)
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