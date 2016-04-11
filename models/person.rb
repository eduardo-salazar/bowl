class Person
	attr_accessible :id, :link, :sex, :name, :img, :mutual_friends

	def to_json
		JSON({  
            id: id,
            img: img,
            link: link
            data: {
              name: name,
              sex: sex,
            }
          },
         options)
	end

end