extends Node

#in chunks
var chunk_no = Vector2(20,20)
#in tiles. Must be >=1.
var chunk_size = Vector2(20,20)

#PRIVATE
onready var districts = get_node("districts")
onready var area = get_node("area")
onready var map = get_node("map")
onready var cam = get_node("../BasicCamera")
# position_of_chunk:tile
var chunk = []

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
		chunk.append([])
		for iy in range(chunk_no.y):
			chunk[ix].append([])
			for xx in range (chunk_size.x):
				chunk[ix][iy].append([])
				for yy in range (chunk_size.y):
					chunk[ix][iy].append([])
					chunk[ix][iy][xx].append([])
					chunk[ix][iy][xx][yy] = {\
									"districts": {"type":int(-1),"position": Vector2(-1,-1)},
									"area": {"type":int(-1)},
									"map": {"type":int(-1)}}
			generate_chunk(chunk[ix][iy])
#	wall_generate()
	update()

func generate_chunk(ch):
	retangle(ch,map,chunk_size,2,true,1) # 2 is a number of tile in the tileset
	district_generator(ch)
	areaing(ch)


func retangle(chunk,layer,wh,t,b=false,bt=null):
	if ((b == false) and (wh.x >= 1) and (wh.y >= 1)):
		for x in range(wh.x):
			for y in range(wh.y):
				chunk[x][y][layer]["type"] = t
		return (true)
	if ((b == true) and (wh.x > 2) and (wh.y > 2) and (typeof(bt)==TYPE_INT)):
		for x in range(wh.x-2):
			for y in range(wh.y-2):
				chunk[x+1][y+1][layer.get_name()]["type"] = t
		for x in range(wh.x):
				chunk[x][0][layer.get_name()]["type"] = bt
				chunk[x][wh.y-1][layer.get_name()]["type"] = bt
		for y in range(wh.y-2):
				chunk[0][y+1][layer.get_name()]["type"] = bt
				chunk[wh.x-1][y+1][layer.get_name()]["type"] = bt
		return (true)
	print("Error 2: Map is too small.")
	return (false)

func update():
	var to_draw_struct = {"map":map,"districts":districts,"area":area}
	for layer in to_draw_struct.keys():
		to_draw_struct[layer].clear()
		for xx in range(chunk_no.x):
			for yy in range(chunk_no.y):
				if ((xx>=0)and(yy>=0)and(xx<chunk_no.x)and(yy<chunk_no.y)):
					for xxx in range(chunk_size.x):
						for yyy in range(chunk_size.y):
							if (chunk[xx][yy][xxx][yyy][layer]!=-1):
								to_draw_struct[layer].set_cell(xx*chunk_size.x+xxx,yy*chunk_size.y+yyy,chunk[xx][yy][xxx][yyy][layer]["type"])

func district_generator(chunk):
	for i in range(5):
		var t
		if (round(randf())>=0.5): #LOLZ
			t = 3
		else:
			t = 4
		var e = true
		var empty = true
		for x in range(chunk.size()):
			for y in range(chunk[x].size()):
				if (chunk[x][y]["districts"]["type"] != -1):
					empty = false
					break
		if (empty == true):
			var v = Vector2(round(rand_range(1,chunk_size.x-1)),round(rand_range(1,chunk_size.y-1)))
			make_district(v,t,chunk)
		else:
			for xx in range(chunk.size()):
				for yy in range(chunk[xx].size()):
					var v = Vector2(round(rand_range(1,chunk_size.x-1)),round(rand_range(1,chunk_size.y-1)))
					if (chunk[xx][yy]["districts"]["position"]==v):
						e = true
					else:
						make_district(v,t,chunk)
						e = false
						break
				if (e == false):
					break
func make_district(position,type,chunk):
	chunk[position.x][position.y]["districts"] = {"type":type,"position":position}
func areaing(chunk):
	var to_expand = {}
	var blokade = []
	for x in range(chunk.size()):
		for y in range(chunk[x].size()):
			if (chunk[x][y]["districts"]!=-1):
				if (chunk[x][y]["districts"]["type"]!=-1):
					to_expand[Vector2(x,y)] = chunk[x][y]["districts"]["type"]
	while(!to_expand.empty()):
		for pos in to_expand.keys():
			if (blokade.has(pos)==false):
				circle(pos,to_expand,chunk)
				blokade.append(pos)
			to_expand.erase(pos)

func circle(pos,to_expand,chunk):
	if (chunk[pos.x][pos.y]["area"]["type"] == -1 ):
		chunk[pos.x][pos.y]["area"]  = {"type":to_expand[pos]+2}
	if ((pos.x-1>=0)):
		if (chunk[pos.x-1][pos.y]["area"]["type"] == -1):
			to_expand[Vector2(pos.x-1,pos.y)] = to_expand[pos]
			chunk[pos.x-1][pos.y]["area"]["type"] = to_expand[pos]+2
	if ((pos.y-1>=0)):
		if (chunk[pos.x][pos.y-1]["area"]["type"] == -1):
			to_expand[Vector2(pos.x,pos.y-1)] = to_expand[pos]
			chunk[pos.x][pos.y-1]["area"]["type"] = to_expand[pos]+2
	if (pos.x+1<chunk_size.x):
		if (chunk[pos.x+1][pos.y]["area"]["type"] == -1):
			to_expand[Vector2(pos.x+1,pos.y)] = to_expand[pos]
			chunk[pos.x+1][pos.y]["area"]["type"] = to_expand[pos]+2
	if (pos.y+1<chunk_size.y):
		if (chunk[pos.x][pos.y+1]["area"]["type"] == -1):
			to_expand[Vector2(pos.x,pos.y+1)] = to_expand[pos]
			chunk[pos.x][pos.y+1]["area"]["type"] = to_expand[pos]+2

func wall_generate():
	var ar=[]
	

	for x in range(chunk_size.x*chunk_no.x):
		ar.append([])
		for y in range(chunk_size.y*chunk_no.y):
			ar[x].append([])
			ar[x][y]={"type":5}

	rect_to_chunk(Vector2(0,0),Vector2(chunk_no.x,chunk_no.y),ar,"area")
func rect_to_chunk(begin,end,from,to):
	for ix in range(begin.x,end.x):
		for iy in range(begin.y,end.y):
			for ixx in range(chunk_size.x):
				for iyy in range(chunk_size.y):
					chunk[ix][iy][ixx][iyy][to] = from[chunk_size.x*ix+ixx][chunk_size.y*iy+iyy]
