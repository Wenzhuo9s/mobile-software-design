package edu.gwu.findacat.activity

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.support.v7.app.AppCompatActivity
import android.text.method.ScrollingMovementMethod
import android.util.Log
import android.view.Menu
import android.view.MenuItem
import com.squareup.picasso.Picasso
import edu.gwu.findacat.Constants
import edu.gwu.findacat.PersistenceManager
import edu.gwu.findacat.R
import edu.gwu.findacat.generated.petfinder.PetItem
import kotlinx.android.synthetic.main.activity_petdetails.*

class PetDetailsActivity:AppCompatActivity(){
    private val TAG = "PetDetailsActivity"
    private lateinit var petItem: PetItem
    private lateinit var persistenceManager: PersistenceManager


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_petdetails)

        setSupportActionBar(pet_details_toolbar)
        supportActionBar!!.setDisplayShowTitleEnabled(false)
        supportActionBar!!.setDisplayHomeAsUpEnabled(true)

        persistenceManager = PersistenceManager(this)

        petItem = intent.getParcelableExtra<PetItem>(PetsActivity.PET_ITEM)
        catDetails(petItem)
    }

    //create a menu
    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menuInflater.inflate(R.menu.menu_petdetails, menu)

        return true
    }

    //prepare favorite item of menu to show if this cat is in favorite list
    override fun onPrepareOptionsMenu(menu: Menu): Boolean {
        val favoritecats = persistenceManager.fetchCats()
        for (i in favoritecats) {
            if (i.id.t == petItem.id.t) {
                petItem.favorite = true
            }
        }
        if (petItem.favorite) {
            menu.findItem(R.id.favor_button).setIcon(R.drawable.baseline_favorite_white_36)
        }else if(!petItem.favorite){
            menu.findItem(R.id.favor_button).setIcon(R.drawable.baseline_favorite_border_white_36)
        }

        return true
    }
    //select items of menu
    override fun onOptionsItemSelected(item: MenuItem):Boolean {
        when (item.itemId) {//home icon,return to last task
            android.R.id.home -> {
                val favor = intent.getStringExtra(Constants.FAVORITE_CAT_KEY)
                val intent = Intent(this@PetDetailsActivity, PetsActivity::class.java)
                if(favor=="0"){
                intent.addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)}
                else if(favor=="1"){
                    intent.putExtra(Constants.FAVORITE_CAT_KEY,"1")
                }
                startActivity(intent)
                finish()
                return true
            }
            R.id.email_button -> {//share via email icon
                val catEmail=petItem.contact.email.t
                val catName=petItem.name.t

                val emailTitle=getString(R.string.email_title,catName)
                val emailAddress = arrayOf(catEmail)

                val emailIntent = Intent()
                emailIntent.type = "message/rfc822"
                emailIntent.action = Intent.ACTION_SEND
                emailIntent.putExtra(Intent.EXTRA_SUBJECT,emailTitle)
                emailIntent.putExtra(Intent.EXTRA_EMAIL,emailAddress)

                startActivity(Intent.createChooser(emailIntent, resources.getText(R.string.email)))
                return true
            }
            R.id.share_button -> {//share via message
                val sendIntent = Intent()

                sendIntent.action = Intent.ACTION_SEND

                val sharePhoto = getString(R.string.share_photo_message, Uri.parse(petItem.media.photos?.photo?.get(3)?.t))
                val shareText = getString(R.string.share_name_message, petItem.name.t)
                val emailText=getString(R.string.share_email_message,petItem.contact.email.t)
                sendIntent.putExtra(Intent.EXTRA_TEXT, shareText+emailText+sharePhoto)
                sendIntent.type = "text/plain"

                startActivity(Intent.createChooser(sendIntent, resources.getText(R.string.share)))
                return true
            }
            R.id.favor_button -> {//click for favorite and unfavorable
                if (!petItem.favorite) {
                    Log.d(TAG, "add favorite cats")
                    petItem.favorite = true
                    persistenceManager.saveCats(petItem)
                    item.setIcon(R.drawable.baseline_favorite_white_36)
                } else if (petItem.favorite) {
                    Log.d(TAG, "remove favorite cats")
                    persistenceManager.removeCats(petItem)
                    item.setIcon(R.drawable.baseline_favorite_border_white_36)
                    petItem.favorite = false
                }
                return true
            }
            else -> return super.onOptionsItemSelected(item)
        }
    }

    private fun catDetails(cat: PetItem) {//get details of cat
        cat_breed_text.text=getString(R.string.cat_breed ,cat.breeds.breed[0].t)
        cat_gender_text.text = getString(R.string.cat_gender,cat.sex.t)
        cat_description_text.text =getString(R.string.cat_description,cat.description.t)
        cat_description_text.movementMethod = ScrollingMovementMethod()
        cat_name_text.text =getString(R.string.cat_name,cat.name.t)
        cat_zip_text.text = getString(R.string.cat_zip,cat.contact.zip.t)
        val url = cat.media.photos?.photo?.get(3)?.t
        Picasso.get().load(url)
            .fit().centerCrop()
            .placeholder(R.drawable.catloading)
            .error(R.drawable.error_place)
            .into(cats_photo)
    }
}