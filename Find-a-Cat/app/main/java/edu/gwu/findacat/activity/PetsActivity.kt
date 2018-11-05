package edu.gwu.findacat.activity

import android.content.Intent
import android.location.Location
import android.os.Bundle
import android.support.v7.app.AlertDialog
import android.support.v7.app.AppCompatActivity
import android.support.v7.widget.GridLayoutManager
import android.util.Log
import android.view.LayoutInflater
import android.view.Menu
import android.view.MenuItem
import android.view.View
import android.widget.EditText
import edu.gwu.findacat.*
import edu.gwu.findacat.generated.geocoding.ResultsItem
import edu.gwu.findacat.generated.petfinder.PetItem
import kotlinx.android.synthetic.main.activity_pets.*
import org.jetbrains.anko.toast

class PetsActivity : AppCompatActivity(),PetsAdapter.OnItemClickListener,LocationDetector.LocationListener,
                     ZipCodeFetcher.ZipSearchCompletionListener,PetFinder.PetSearchCompletionListener{

    private val TAG = "PetsActivity"

    companion object {
        const val PET_ITEM = "petItem"
        var ZIP_CODE = "22202"
    }

    private lateinit var petFinder: PetFinder
    private lateinit var petsAdapter: PetsAdapter
    private lateinit var persistenceManager: PersistenceManager
    private lateinit var zipCodeFetcher: ZipCodeFetcher
    private lateinit var locationDetector: LocationDetector


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_pets)

        //Set a support action bar
        setSupportActionBar(pet_toolbar)
        supportActionBar!!.setDisplayShowTitleEnabled(false)
        supportActionBar?.setDisplayHomeAsUpEnabled(true)

        //get String from MenuActivity, and separate nearby cats and favorite cats
        val favor = intent.getStringExtra(Constants.FAVORITE_CAT_KEY)

        if (favor=="0"){//show nearby cats
            locationDetector = LocationDetector(this)
            locationDetector.locationListener =this
            locationDetector.detectLocation()

            zipCodeFetcher = ZipCodeFetcher(this)
            zipCodeFetcher.zipSearchCompletionListener = this

            petFinder = PetFinder(this)
            petFinder.petSearchCompletionListener = this


        }else if(favor=="1"){//show favorite cats
            persistenceManager = PersistenceManager(this)

            val cats = persistenceManager.fetchCats()
            Log.d(TAG, "Fetch Success")
            updatePetItems(cats)

            nearby_cat_text.text = getString(R.string.favorite_cats)
        }

    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "onDestroy called.")
    }


    override fun onResume(){
        super.onResume()
        val favor = intent.getStringExtra(Constants.FAVORITE_CAT_KEY)
        if(favor == "0"){
            petFinder.catFinder(ZIP_CODE)}
        else if(favor == "1"){
        val cats = persistenceManager.fetchCats()
        updatePetItems(cats)
        nearby_cat_text.text = getString(R.string.favorite_cats)
    }
    }

    //Create Menu
    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menuInflater.inflate(R.menu.menu_pets, menu)

        return super.onCreateOptionsMenu(menu)
    }

   //Select Menu items
    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {
            android.R.id.home -> {//home icon,
                val intent = Intent(this@PetsActivity, MenuActivity::class.java)
                intent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)
                startActivity(intent)
                finish()
                true
            }
            R.id.locatondetector -> {//location icon
                onCreateZipDialog()//show alert dialog
                true
            }
            else -> super.onOptionsItemSelected(item)
        }
    }

    //update cat information
    private fun updatePetItems(cats: List<PetItem>){
        petsAdapter = PetsAdapter(cats,this)
        petsAdapter.notifyDataSetChanged()

        cat_list.layoutManager = GridLayoutManager(this,2)
        cat_list.adapter=petsAdapter
    }

    //interface for Location Detector
    override fun locationFound(location: Location) {
        zipCodeFetcher.zipFetch("${location.latitude},${location.longitude}")

    }

    override fun locationNotFound(reason: LocationDetector.FailureReason) {
        when (reason) {
            LocationDetector.FailureReason.TIMEOUT -> toast(getString(R.string.location_not_found))
            LocationDetector.FailureReason.NO_PERMISSION -> toast(getString(R.string.no_location_permission))
        }
    }

    //interface for Petfinder
    override fun catLoaded(cats: List<PetItem>) {
        updatePetItems(cats)
        Log.d(TAG, "Loaded Successed")
    }

    override fun catNotLoaded() {
        toast(getString(R.string.petfinder_failed))
        Log.d(TAG, "Loaded Failed")
    }

    //interface for ZipCodeFetcher
    override fun zipLoaded(zipCode: List<ResultsItem>) {
            for (item in zipCode[0].addressComponents) {
                if (item.longName.length == 5 && item.types.first() == "postal_code") {
                    ZIP_CODE = item.longName
                }
            }
        toast(getString(R.string.cat_zip,"${ZIP_CODE}"))
        petFinder.catFinder(ZIP_CODE)
        Log.d(TAG,"Loaded Successful")
    }

    override fun zipNotLoaded() {
        toast(getString(R.string.internet))
        Log.d(TAG,"ZipCode Loaded Failed")
    }

    //AlertDialog for User input zipCode
    private fun onCreateZipDialog() {
        // loading dialog layout
        val layoutInflater = LayoutInflater.from(this)
        val zipView = layoutInflater.inflate(R.layout.dialog_setzip,null)

        val alertDialogBuilder = AlertDialog.Builder(
            this)

        alertDialogBuilder.setView(zipView)

        val zip  = zipView.findViewById<EditText>(R.id.zip_edit)
        val favor = intent.getStringExtra(Constants.FAVORITE_CAT_KEY)

        // set Dialog buttons
        alertDialogBuilder
            .setCancelable(false)
            .setPositiveButton(getString(R.string.OK)) { _, _ ->
                // get edittext context
                ZIP_CODE = zip.text.toString()
                if(ZIP_CODE!=""){
                    if(ZIP_CODE.length==5){
                        toast(getString(R.string.cat_zip, ZIP_CODE))
                        val cats= emptyList<PetItem>().toMutableList()//emptylist for favorite cats in a range
                        if(favor=="0"){
                        petFinder.catFinder(ZIP_CODE)}
                        else if(favor=="1"){
                            val catslist = persistenceManager.fetchCats()
                            for (item in catslist){
                                if(ZIP_CODE==item.contact.zip.t){
                                    cats.add(item)
                                }
                            }
                            updatePetItems(cats)
                        }
                    }else{
                        toast(getString(R.string.enter_error))
                    }
                }
                else{
                    toast(getString(R.string.no_zip_found))
                }
            }
            .setNegativeButton(getString(R.string.Cancel)){ dialog, _ -> dialog.cancel()
            }

        // create alert dialog
        val alertDialog = alertDialogBuilder.create()
        // show it
        alertDialog.show()
    }

    //interface for petsAdapter
    override fun onItemClick(cat: PetItem, itemView: View) {
        val favor = intent.getStringExtra(Constants.FAVORITE_CAT_KEY)
        val detailsIntent = Intent(this, PetDetailsActivity::class.java)
        detailsIntent.putExtra(PET_ITEM, cat)
        detailsIntent.putExtra(Constants.FAVORITE_CAT_KEY,favor)
        startActivity(detailsIntent)
    }

}