package edu.gwu.findacat
import android.content.ContentValues
import android.content.Context
import android.content.SharedPreferences
import android.preference.PreferenceManager
import android.util.Log
import com.squareup.moshi.Moshi
import com.squareup.moshi.Types
import edu.gwu.findacat.generated.petfinder.PetItem
import java.io.IOException

class PersistenceManager(context: Context){
    private val sharedPreferences: SharedPreferences = PreferenceManager.getDefaultSharedPreferences(context)

    fun saveCats(cat: PetItem){
        val cats= fetchCats().toMutableList()
        cats.add(cat)

        val editor=sharedPreferences.edit()

        //convert a list of scores into a JSON string
        val moshi = Moshi.Builder().build()
        val listType = Types.newParameterizedType(List::class.java, PetItem::class.java)
        val jsonAdapter = moshi.adapter<List<PetItem>>(listType)
        val jsonString = jsonAdapter.toJson(cats)

        editor.putString(Constants.CAT_PREF_KEY,jsonString)

        editor.apply()

    }

    fun removeCats(cat: PetItem){
        val cats= fetchCats().toMutableList()
        cats.remove(cat)

        val editor=sharedPreferences.edit()

        //convert a list of scores into a JSON string
        val moshi = Moshi.Builder().build()
        val listType = Types.newParameterizedType(List::class.java, PetItem::class.java)
        val jsonAdapter = moshi.adapter<List<PetItem>>(listType)
        val jsonString = jsonAdapter.toJson(cats)

        editor.putString(Constants.CAT_PREF_KEY,jsonString)

        editor.apply()

    }

    fun fetchCats():List<PetItem>{
        val jsonString = sharedPreferences.getString(Constants.CAT_PREF_KEY,null)

        if(jsonString==null){
            return arrayListOf<PetItem>()
        } else{
            val listType=Types.newParameterizedType(List::class.java,PetItem::class.java)
            val moshi=Moshi.Builder()
                    .build()
            val jsonAdapter=moshi.adapter<List<PetItem>>(listType)

            var cats:List<PetItem>?= emptyList<PetItem>()

            try{
                cats = jsonAdapter.fromJson(jsonString)
            }catch (e: IOException){
                Log.e(ContentValues.TAG,e.message)
            }

            return if(cats !=null){
                cats
            } else{
                emptyList<PetItem>()
            }
        }
    }
    fun favoritedCat():List<PetItem>{
        val cats = fetchCats()

        return cats
    }
}