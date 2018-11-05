@file:Suppress("DEPRECATION")
package edu.gwu.findacat

import android.app.ProgressDialog
import android.content.Context
import android.util.Log
import com.squareup.moshi.*
import com.squareup.moshi.kotlin.reflect.KotlinJsonAdapterFactory
import edu.gwu.findacat.generated.geocoding.GeocodingResponse
import edu.gwu.findacat.generated.geocoding.ResultsItem
import retrofit2.Retrofit
import retrofit2.converter.moshi.MoshiConverterFactory
import retrofit2.http.Query
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import retrofit2.http.GET
import java.lang.reflect.Type

class ZipCodeFetcher(private val context: Context){


    private val TAG = "ZipCodeFetcher"
    var zipSearchCompletionListener: ZipSearchCompletionListener? = null


    interface ZipSearchCompletionListener {
        fun zipLoaded(zipCode:List<ResultsItem>)
        fun zipNotLoaded()
    }

    interface ApiEndpointInterface {
        @GET("/maps/api/geocode/json")
        fun getGeocoderResponse(@Query("key")key:String,
                               @Query("latlng")latlng:String):Call<GeocodingResponse>

    }

    fun zipFetch(latlng: String) {

        val moshi = Moshi.Builder()
            .add(KotlinJsonAdapterFactory())
            .add(PetFinder.ObjectAsListJsonAdapterFactory())
            .build()

        val retrofit = Retrofit.Builder()
            .baseUrl("https://maps.googleapis.com")
            .addConverterFactory(MoshiConverterFactory.create(moshi))
            .build()

        val apiEndpoint = retrofit.create(ApiEndpointInterface::class.java)
        val progressDialog = ProgressDialog(context)
        progressDialog.setMessage(context.getString(R.string.zip_fetching))
        progressDialog.setCancelable(false)
        progressDialog.show()

        apiEndpoint.getGeocoderResponse("AIzaSyDuPwMfANhG66ojTm6pIaX5dEm6sRm2TVc","${latlng}")
            .enqueue(object : Callback<GeocodingResponse> {
                override fun onFailure(call: Call<GeocodingResponse>, t: Throwable) {
                    Log.e(TAG, "API call failed!", t)
                    progressDialog.dismiss()
                    zipSearchCompletionListener?.zipNotLoaded()

                }

                override fun onResponse(call: Call<GeocodingResponse>, response: Response<GeocodingResponse>) {
                    val geocoderResponseBody = response.body()
                    progressDialog.dismiss()
                    Log.d(TAG, "response Successful")
                    //progressDialog.dismiss()
                    geocoderResponseBody?.results?.let { zipSearchCompletionListener?.zipLoaded(it)
                        return}
                    zipSearchCompletionListener?.zipNotLoaded()
                }


            })
    }

    /**
     *
     * The adapter Wraps an encountered Objects in a List whenever a List<T> was expected but an
     * Object was encountered in the JSON
     */

    class ObjectAsListJsonAdapterFactory : JsonAdapter.Factory {
        override fun create(type: Type, annotations: MutableSet<out Annotation>, moshi: Moshi): JsonAdapter<*>? {
            if (!List::class.java.isAssignableFrom(Types.getRawType(type))) {
                return null
            }
            val listDelegate = moshi.nextAdapter<List<Any>>(this, type, annotations)
            val innerType = Types.collectionElementType(type, List::class.java)
            val objectDelegate = moshi.adapter<Any>(innerType, annotations)
            return ListJsonAdapter(listDelegate, objectDelegate) as JsonAdapter<Any>
        }

        inner class ListJsonAdapter<T>(private val listDelegate: JsonAdapter<List<T>>,
                                       private val objectDelegate: JsonAdapter<T>
        ) : JsonAdapter<List<T>>() {

            override fun fromJson(reader: JsonReader): List<T>? {
                if (reader.peek() == JsonReader.Token.BEGIN_OBJECT) {
                    objectDelegate.fromJson(reader)?.let { return arrayListOf(it) } ?: return null
                } else {
                    return listDelegate.fromJson(reader)
                }
            }

            override fun toJson(writer: JsonWriter, value: List<T>?) {
                listDelegate.toJson(writer, value)
            }
        }
    }
}