extends TileMap

#in chunks
var chunk_no = Vector2(20,20)
#in tiles. Must be >=1.
var chunk_size = Vector2(20,20)

#PRIVATE
onready var distr_tilemap = get_node("Districts")
onready var distr_area_tilemap = get_node("Districts_area")

# position_of_chunk:tile
var chunk = {}
# position_in_chunk:{values:keys}


func _ready():
	generate()
	
func generate():
	chunk.clear()
	randomize()
	
	for ix in range(chunk_no.x):
		for iy in range(chunk_no.y):
			var tile={}
			chunk[Vector2(ix,iy)] = {}
			for xx in range (chunk_size.x):
				for yy in range (chunk_size.y):
					tile[Vector2(xx,yy)]={\
						"districts": int(-1),
						"area": int(-1),
						"type": int(-1)}
					chunk[Vector2(ix,iy)][Vector2(xx,yy)] = tile[Vector2(xx,yy)]
			generate_chunk(chunk[Vector2(ix,iy)])
	update()
	
func generate_chunk(ch):

	retangle(ch,chunk_size,2,true,1) # 2 is a number of tile in the tileset
#	retangle(ch,chunk_size,2,false) # 2 is a number of tile in the tileset

#	district_generator()
#	areaing()
#	city_generate()


func retangle(chunk,wh,t,b=false,bt=null):
	if ((b == false) and (wh.x >= 1) and (wh.y >= 1)):
		for x in range(wh.x):
			for y in range(wh.y):
				chunk[Vector2(x,y)]["type"] = t
		return (true)
		
	if ((b == true) and (wh.x > 2) and (wh.y > 2) and (typeof(bt)==TYPE_INT)):
		for x in range(wh.x-2):
			for y in range(wh.y-2):
				chunk[Vector2(x+1,y+1)]["type"] = t
		for x in range(wh.x):
				chunk[Vector2(x,0)]["type"] = bt
				chunk[Vector2(x,wh.y-1)]["type"] = bt
		for y in range(wh.y-2):
				chunk[Vector2(0,y+1)]["type"] = bt
				chunk[Vector2(wh.x-1,y+1)]["type"] = bt
		return (true)
	print("Error 2: Map is too small.")
	return (false)
func update():
	for xx in range(chunk_no.x):
		for yy in range(chunk_no.y):
			for xxx in range(chunk_size.x):
				for yyy in range(chunk_size.y):
					set_cell(xx*chunk_size.x+xxx,yy*chunk_size.y+yyy,chunk[Vector2(xx,yy)][Vector2(xxx,yyy)]["type"])
	
#func map_resize(size):
#	map_content.clear()
#	area.clear()
#	area = {}
#	for x in range(size.x):
#		map_content.append([])
#		for y in range(size.y):
#			map_content[x].append(null)
#	map_district.clear()
#	distr_area.clear()
#func redraw():
#	clear()
#	for x in range(map_size.x):
#		for y in range(map_size.y):
#			if (typeof(map_content[x][y])!=TYPE_INT):
#				print("Error 1: No data at map cell. Occurs at cell " + str(x) +" " + str(y))
#				return (false)
#			set_cell(x,y,map_content[x][y])
#	for x in range(map_size.x):
#		for y in range(map_size.y):
#			for i in map_district.keys():
#				if map_district[i]["position"] == Vector2(x,y):
#					distr.set_cell(x,y,map_district[i]["type"])
#	for x in range(map_size.x):
#		for y in range(map_size.y):
#			for i in area.keys():
#				if i == Vector2(x,y):
#					distr_area.set_cell(x,y,area[i])
#func district_generator():
#	for i in range(15):
#		var t
#		if (round(randf())>=0.5):
#			t = 3
#		else:
#			t = 4
#		var e = true
#		if (map_district.values().size()==0):
#			var v = Vector2(round(rand_range(1,map_size.x-1)),round(rand_range(1,map_size.y-1)))
#			make_district(v,t)
#		else:
#			for i in map_district.values():
#				var v = Vector2(round(rand_range(1,map_size.x-1)),round(rand_range(1,map_size.y-1)))
#				if (i==v):
#					e = true
#				else:
#					make_district(v,t)
#					e = false
#					break
#func make_district(position,type):
#	map_district[str(map_district.size())] = {"position":position,"type":type}
#func circle(pos,to_expand,t):
#	if (area.has(pos)==false):
#		if ((t != 5) or (t!=6)):
#			area[pos] = t+2
#	if ((area.has(Vector2(pos.x-1,pos.y))==false) and !(pos.x-1<0)):
#		if ((t != 5) or (t!=6)):
#			area[Vector2(pos.x-1,pos.y)] = t+2
#		to_expand[Vector2(pos.x-1,pos.y)] = t
#	if ((area.has(Vector2(pos.x,pos.y-1))==false) and !(pos.y-1<0)):
#		if ((t != 5) or (t!=6)):
#			area[Vector2(pos.x,pos.y-1)] = t+2
#		to_expand[Vector2(pos.x,pos.y-1)] = t
#	if ((area.has(Vector2(pos.x+1,pos.y))==false) and !(pos.x+1>map_size.x)):
#		if ((t != 5) or (t!=6)):
#			area[Vector2(pos.x+1,pos.y)] = t+2
#		to_expand[Vector2(pos.x+1,pos.y)] = t
#	if ((area.has(Vector2(pos.x,pos.y+1))==false) and !(pos.y+1>map_size.y)):
#		if ((t != 5) or (t!=6)):
#			area[Vector2(pos.x,pos.y+1)] = t+2
#		to_expand[Vector2(pos.x,pos.y+1)] = t
#func areaing():
#	var to_expand={}
#	var blokade = {}
#	for i in map_district.values():
#		to_expand[i["position"]] = i["type"]
#	while(!to_expand.empty()):
#		for i in to_expand.keys():
#			print(to_expand)
#			if (blokade.has(i)==false):
#				circle(i,to_expand,to_expand[i])
#				blokade[i]=null
#				to_expand.erase(i)
#			else:
#				to_expand.erase(i)
#func city_generate():
#	retangle(map_size,Vector2(0,0),5,false,null)
#	