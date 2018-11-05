@file:Suppress("DEPRECATION")
package edu.gwu.findacat

import android.app.ProgressDialog
import android.content.Context
import android.util.Log
import com.squareup.moshi.*
import com.squareup.moshi.kotlin.reflect.KotlinJsonAdapterFactory
import edu.gwu.findacat.generated.petfinder.PetFinderResponse
import edu.gwu.findacat.generated.petfinder.PetItem
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import retrofit2.Retrofit
import retrofit2.converter.moshi.MoshiConverterFactory
import retrofit2.http.GET
import retrofit2.http.Query
import java.lang.reflect.Type

class PetFinder(private val context: Context) {
    private val TAG = "PetFinder"
    var petSearchCompletionListener: PetSearchCompletionListener? = null

    interface PetSearchCompletionListener {
        fun catLoaded(cats:List<PetItem>)
        fun catNotLoaded()
    }

    interface ApiEndpointInterface {
        @GET("pet.find")
        fun getPetFinderResponse(@Query("key")key:String,
                                 @Query("format")format:String,
                                 @Query("animal")animal:String,
                                 @Query("location")location:String): Call<PetFinderResponse>

    }

    fun catFinder(zipcode:String) {
        val moshi = Moshi.Builder()
            .add(ObjectAsListJsonAdapterFactory())
            .add(KotlinJsonAdapterFactory())
            .build()

        val retrofit = Retrofit.Builder()
            .baseUrl(Constants.PETFINDER_SEARCH_URL)
            .addConverterFactory(MoshiConverterFactory.create(moshi))
            .build()

        val apiEndpoint = retrofit.create(PetFinder.ApiEndpointInterface::class.java)

        val progressDialog = ProgressDialog(context)
        progressDialog.setMessage(context.getString(R.string.image_downloading))
        progressDialog.setCancelable(false)
        progressDialog.show()

        apiEndpoint.getPetFinderResponse("7a8cc433db127e9c3837ddc3abd3e32e","json","cat","${zipcode}")
            .enqueue(object : Callback<PetFinderResponse> {
                override fun onFailure(call: Call<PetFinderResponse>, t: Throwable) {
                    Log.e(TAG, "API call failed!", t)
                    petSearchCompletionListener?.catNotLoaded()
                    progressDialog.dismiss()
                }

                override fun onResponse(call: Call<PetFinderResponse>, response: Response<PetFinderResponse>) {
                    val petFinderResponseBody = response.body()
                    Log.d(TAG,"response Successful")
                    progressDialog.dismiss()

                    petFinderResponseBody?.petfinder?.pets?.pet?.let {
                        petSearchCompletionListener?.catLoaded(it)
                        Log.d(TAG,"return Successful")
                        return
                    }
                    petSearchCompletionListener?.catNotLoaded()
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
                                       private val objectDelegate: JsonAdapter<T>) : JsonAdapter<List<T>>() {

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