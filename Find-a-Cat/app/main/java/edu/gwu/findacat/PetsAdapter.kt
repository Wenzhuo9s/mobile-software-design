package edu.gwu.findacat

import android.support.v7.widget.RecyclerView
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import com.squareup.picasso.Picasso
import edu.gwu.findacat.generated.petfinder.PetItem


class PetsAdapter(private val cats:List<PetItem>, private val clickListener: OnItemClickListener):
    RecyclerView.Adapter<PetsAdapter.ViewHolder>() {
    private var TAG ="PetsAdapter"

    override fun onCreateViewHolder(viewGroup: ViewGroup, viewType: Int): ViewHolder {
        val layoutInflater= LayoutInflater.from(viewGroup.context)

        return ViewHolder(layoutInflater.inflate(R.layout.layout_cat_list, viewGroup, false))
    }

    override fun getItemCount(): Int {
        return cats.size
    }

    override fun onBindViewHolder(viewHolder: ViewHolder, position: Int) {
        val cat = cats.get(position)
        viewHolder.bind(cat,clickListener)
    }

    inner class ViewHolder(view: View): RecyclerView.ViewHolder(view) {
        private val catname: TextView = view.findViewById(R.id.catName)
        private val catimage: ImageView = view.findViewById(R.id.catImage)

        fun bind(cat: PetItem, listener: OnItemClickListener) = with(itemView) {

            var uri =cat.media.photos?.photo?.get(3)?.t
            Log.d(TAG, "found url: $uri")
            Picasso.get().load(uri).fit().centerCrop()
                .placeholder(R.drawable.catloading)
                .error(R.drawable.error_place)
                .into(catimage)

            catname.text=cat.name.t
            setOnClickListener {
                listener.onItemClick(cat, it)
            }
        }

    }

    interface OnItemClickListener {
        fun onItemClick(cat:PetItem, itemView: View)
    }


}