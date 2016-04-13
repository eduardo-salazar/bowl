class Person
	attr_accessor :id, :link, :sex, :name, :img, :mutual_friends

	def to_json
		JSON({  id: id,
            img: img,
            link: link,
            data: {
              name: name,
              sex: sex,
            }
          })
	end

end