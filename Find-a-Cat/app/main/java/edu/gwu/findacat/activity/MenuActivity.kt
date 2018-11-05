package edu.gwu.findacat.activity

import android.content.Intent
import android.content.pm.PackageManager
import android.support.v7.app.AppCompatActivity
import android.os.Bundle
import android.support.v4.app.ActivityCompat
import android.support.v4.content.ContextCompat
import android.util.Log
import edu.gwu.findacat.CatFactFetcher
import edu.gwu.findacat.Constants
import edu.gwu.findacat.R
import kotlinx.android.synthetic.main.activity_menu.*
import org.jetbrains.anko.toast

class MenuActivity : AppCompatActivity(),CatFactFetcher.FactSearchCompletionListener {
    val TAG="MenuActivity"
    private val LOCATION_PERMISSION_REQUEST_CODE = 7
    private lateinit var catFactFetcher: CatFactFetcher

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_menu)

        catFactFetcher = CatFactFetcher(this)
        catFactFetcher.factSearchCompletionListener = this

        catFactFetcher.factFetched()


        findacat_button.setOnClickListener {
            //click button "find a cat"
            Log.d(TAG, "Find a Cat")
            val intent = Intent(this@MenuActivity, PetsActivity::class.java)
            intent.putExtra(Constants.FAVORITE_CAT_KEY,"0")
            startActivity(intent)
        }

        favourite_cats_button.setOnClickListener {
            //click button "favorite cats"
            Log.d(TAG, "Favorite Cats")
            val intent = Intent(this@MenuActivity, PetsActivity::class.java)
            intent.putExtra(Constants.FAVORITE_CAT_KEY,"1")
            startActivity(intent)
        }

        requestPermissionsIfNecessary()
    }

    //request location permission
    private fun requestPermissionsIfNecessary() {
        val permission = ContextCompat.checkSelfPermission(this, android.Manifest.permission.ACCESS_FINE_LOCATION)
        if(permission != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, arrayOf(android.Manifest.permission.ACCESS_FINE_LOCATION), LOCATION_PERMISSION_REQUEST_CODE)
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        if(requestCode == LOCATION_PERMISSION_REQUEST_CODE) {
            if(grantResults.isNotEmpty() && grantResults.first() == PackageManager.PERMISSION_GRANTED) {
                toast(R.string.permissions_granted)
            }
            else {
                toast(R.string.permissions_denied)
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "onDestroy called.")
    }

    //interface for CatFactFetcher
    override fun factfetched(fact: String) {
        Log.d(TAG,"Loaded successful")
        cat_facts_text.text = getString(R.string.cat_facts,fact)
    }

    override fun factnotfetched() {
        Log.d(TAG,"Loaded failed")

    }
}
