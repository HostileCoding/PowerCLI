package hostilecoding.tk.HTTPPostExample;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import org.apache.http.NameValuePair;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.ResponseHandler;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.BasicResponseHandler;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import android.annotation.SuppressLint;
import android.annotation.TargetApi;
import android.app.Activity;
import android.app.ProgressDialog;
import android.os.AsyncTask;
import android.os.Build;
import android.os.Bundle;
import android.text.method.ScrollingMovementMethod;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.EditText;
import android.widget.TextView;

public class HTTPPostExample extends Activity implements OnClickListener{
	
	private TextView resultText;
	private EditText inputText;
	private String inputCommandText;
	private ProgressDialog pd;
	private String response=null; 
	
	public void onCreate(Bundle icicle) {
		super.onCreate(icicle);
		setContentView(R.layout.main);
		
		View sendData = findViewById(R.id.sendData);
		sendData.setOnClickListener(this);
		
		 //TextView
	     resultText = (TextView) findViewById(R.id.output);
	     resultText.setMovementMethod(ScrollingMovementMethod.getInstance());
	    
	     //EditText
	     inputText = (EditText) findViewById(R.id.input);
	     inputText.setMovementMethod(ScrollingMovementMethod.getInstance());
		
	}
	
	public void onClick(View view){
		switch (view.getId()) {
		
		case R.id.sendData:
			
			pd = ProgressDialog.show(HTTPPostExample.this, "Running PowerCLI","Please wait...",true,false); //Show ProcessDialog
			
			RunPowerCli task = new RunPowerCli(); 
			task.execute(); //Run task

			
		break;
		}
	}
	
	//Asynch Task
	@TargetApi(Build.VERSION_CODES.CUPCAKE)
	@SuppressLint("NewApi")
	private class RunPowerCli extends AsyncTask<String, Void, String> {

        @Override
        protected String doInBackground(String... params) {
            
        	inputCommandText = inputText.getText().toString().replaceAll("\\n", ";"); //Every command must be separated using ;
        	
        	this.postData("sendpowercli", inputCommandText.toString().replaceAll("#[^;]*", "")); //Ignore PowerCLI comments
        	
            return response;
        }

        @Override
        protected void onPostExecute(String result) { //When execution completed set text
            TextView txt = (TextView) findViewById(R.id.output);
            txt.setText(response); 
            pd.dismiss();
        }

        @Override
        protected void onPreExecute() {}

        @Override
        protected void onProgressUpdate(Void... values) {}
        
        
        public String postData(String method, String value) {
        	
    		HttpClient httpclient = new DefaultHttpClient();
    		HttpPost httppost = new HttpPost("http://10.0.0.129/android.php"); //Back-end PHP page

    		try {
    			List<NameValuePair> nameValuePairs = new ArrayList<NameValuePair>(1);
    			nameValuePairs.add(new BasicNameValuePair(method, value)); //value to post and method to trigger
    	
    			httppost.setEntity(new UrlEncodedFormEntity(nameValuePairs));
    	
    			// Execute HTTP Post
    			ResponseHandler<String> responseHandler = new BasicResponseHandler();
    			response = httpclient.execute(httppost, responseHandler);

    		} catch (ClientProtocolException e) {

    		// TODO Auto-generated catch block
    		} catch (IOException e) {
    		
    		// TODO Auto-generated catch block
    		}
			return response;

    	}
        
    }


	
}
