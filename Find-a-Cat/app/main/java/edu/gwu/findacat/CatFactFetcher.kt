
package edu.gwu.findacat

import android.app.ProgressDialog
import android.content.Context
import android.util.Log
import edu.gwu.findacat.generated.CatFactsResponse
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import retrofit2.Retrofit
import retrofit2.converter.moshi.MoshiConverterFactory
import retrofit2.http.GET

class CatFactFetcher(private val context: Context) {
    private val TAG = "CatFactFetcher"
    var factSearchCompletionListener: FactSearchCompletionListener? = null

    interface FactSearchCompletionListener{
        fun factfetched(fact: String)
        fun factnotfetched()
    }

    interface ApiEndpointInterface {
        @GET("/fact")
        fun getCatFactResponse(): Call<CatFactsResponse>
    }

    fun factFetched() {
        val retrofit = Retrofit.Builder()
            .baseUrl(Constants.REQUEST_URL)
            .addConverterFactory(MoshiConverterFactory.create())
            .build()

        val apiEndpoint = retrofit.create(ApiEndpointInterface::class.java)
        val progressDialog = ProgressDialog(context)
        progressDialog.setMessage(context.getString(R.string.fact_fetching))
        progressDialog.setCancelable(false)
        progressDialog.show()

        apiEndpoint.getCatFactResponse().enqueue(object : Callback<CatFactsResponse> {
            override fun onFailure(call: Call<CatFactsResponse>, t: Throwable) {
                Log.d(TAG, "API Call Failed")
                progressDialog.dismiss()
            }

            override fun onResponse(call: Call<CatFactsResponse>, response: Response<CatFactsResponse>) {
                val factResponseBody = response.body()
                Log.d(TAG, "API Call Successful")
                progressDialog.dismiss()
                if (factResponseBody != null) {
                    factSearchCompletionListener?.factfetched(factResponseBody.fact)

                }else{
                    factSearchCompletionListener?.factnotfetched()
                }
            }

        })
    }
}
