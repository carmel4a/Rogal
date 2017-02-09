extends TileMap

#in chunks
var chunk_no = Vector2(3,3)
#in tiles. Must be >=1.
var chunk_size = Vector2(10,10)

#PRIVATE
onready var districts = get_node("districts")
onready var area = get_node("area")
onready var cam = get_node("../Camera")
# position_of_chunk:tile
var chunk = {}

# These two vectors have: 1st - begining; 2st - end of visable chunks retangle
#	Vector2(floor((cam.get_global_pos().x*(1/cam.get_zoom().x) - get_viewport_rect().size.x/2) / ((chunk_size.x*32 * (1/cam.get_zoom().x)))),\
#		floor((cam.get_global_pos().y*(1/cam.get_zoom().y) - get_viewport_rect().size.y/2) / ((chunk_size.y*32 * (1/cam.get_zoom().y)))))
#	Vector2(floor((cam.get_global_pos().x*(1/cam.get_zoom().x) + get_viewport_rect().size.x/2) / ((chunk_size.x*32 * (1/cam.get_zoom().x)))),\
#		floor((cam.get_global_pos().y*(1/cam.get_zoom().y) + get_viewport_rect().size.y/2) / ((chunk_size.y*32 * (1/cam.get_zoom().y)))))
func _ready():
	generate()

func generate():
	chunk.clear()
	randomize()
	for ix in range(chunk_no.x):
		for iy in range(chunk_no.y):
			chunk[Vector2(ix,iy)] = {}
			for xx in range (chunk_size.x):
				for yy in range (chunk_size.y):
					chunk[Vector2(ix,iy)][Vector2(xx,yy)] = {\
									"districts": {"type":int(-1),"position": Vector2(-1,-1)},
									"area": {"type":int(-1)},
									"type": int(-1)}
			generate_chunk(chunk[Vector2(ix,iy)])
	update()

func generate_chunk(ch):
	retangle(ch,chunk_size,2,true,1) # 2 is a number of tile in the tileset
	district_generator(ch)
	areaing(ch)
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
	var to_draw_struct = {"":null,"districts":districts,"area":area}
	clear()
	for layer in to_draw_struct.keys():
		if (layer != ""):
			to_draw_struct[layer].clear()
		for xx in range(chunk_no.x):
			for yy in range(chunk_no.y):
				if ((xx>=0)and(yy>=0)and(xx<chunk_no.x)and(yy<chunk_no.y)):
					for xxx in range(chunk_size.x):
						for yyy in range(chunk_size.y):
							if (layer != ""):
								if (chunk[Vector2(xx,yy)][Vector2(xxx,yyy)][layer]!=-1):
									to_draw_struct[layer].set_cell(xx*chunk_size.x+xxx,yy*chunk_size.y+yyy,chunk[Vector2(xx,yy)][Vector2(xxx,yyy)][layer]["type"])
							else:
								set_cell(xx*chunk_size.x+xxx,yy*chunk_size.y+yyy,chunk[Vector2(xx,yy)][Vector2(xxx,yyy)]["type"])

func district_generator(chunk):
	for i in range(5):
		var t
		if (round(randf())>=0.5):
			t = 3
		else:
			t = 4
		var e = true
		var empty = true
		for c in chunk.keys():
			if (chunk[c]["districts"] != -1):
				empty = false
				break
		if (empty == true):
			var v = Vector2(round(rand_range(1,chunk_size.x-1)),round(rand_range(1,chunk_size.y-1)))
			make_district(v,t,chunk)
		else:
			for cc in chunk.keys():

				var v = Vector2(round(rand_range(1,chunk_size.x-1)),round(rand_range(1,chunk_size.y-1)))
				if (chunk[cc]["districts"]["position"]==v):
					e = true
				else:
					make_district(v,t,chunk)
					e = false
					break
func make_district(position,type,chunk):
	chunk[position]["districts"] = {"type":type,"position":position}

func areaing(chunk):
	var to_expand = {}
	var blokade = []
	for pos in chunk.keys():
		if (chunk[pos]["districts"]!=-1):
			if (chunk[pos]["districts"]["type"]!=-1):
				to_expand[pos] = chunk[pos]["districts"]["type"]
	while(!to_expand.empty()):
		for pos in to_expand.keys():
			if (blokade.has(pos)==false):
				circle(pos,to_expand,chunk)
				blokade.append(pos)
			to_expand.erase(pos)

func circle(pos,to_expand,chunk):
	if (chunk[pos]["area"]["type"] == -1 ):
		chunk[pos]["area"]  = {"type":to_expand[pos]+2}
	if ((pos.x-1>=0)):
		if (chunk[Vector2(pos.x-1,pos.y)]["area"]["type"] == -1):
			to_expand[Vector2(pos.x-1,pos.y)] = to_expand[pos]
			chunk[Vector2(pos.x-1,pos.y)]["area"]["type"] = to_expand[pos]+2
	if ((pos.y-1>=0)):
		if (chunk[Vector2(pos.x,pos.y-1)]["area"]["type"] == -1):
			to_expand[Vector2(pos.x,pos.y-1)] = to_expand[pos]
			chunk[Vector2(pos.x,pos.y-1)]["area"]["type"] = to_expand[pos]+2
	if (pos.x+1<chunk_size.x):
		if (chunk[Vector2(pos.x+1,pos.y)]["area"]["type"] == -1):
			to_expand[Vector2(pos.x+1,pos.y)] = to_expand[pos]
			chunk[Vector2(pos.x+1,pos.y)]["area"]["type"] = to_expand[pos]+2
	if (pos.y+1<chunk_size.y):
		if (chunk[Vector2(pos.x,pos.y+1)]["area"]["type"] == -1):
			to_expand[Vector2(pos.x,pos.y+1)] = to_expand[pos]
			chunk[Vector2(pos.x,pos.y+1)]["area"]["type"] = to_expand[pos]+2

#func city_generate():
#	retangle(map_size,Vector2(0,0),5,false,null)
#	