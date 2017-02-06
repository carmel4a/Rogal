extends TileMap

#verry cpu expensive. It should be used with chunks
var map_size = Vector2(20,20)
# map_content = {}
# map_content[Vector(x,y)] = {layer1:value,layer2:value 2 = {var1:a}, ...}

var map_content = []
var map_district = {}
var area = {}
onready var distr = get_node("Districts")
onready var distr_area = get_node("Districts_area")
func _ready():
	generate()
	
func generate():
	randomize()
	map_resize(map_size)
	retangle(map_size,Vector2(0,0),2,false,1)
	distr.clear()
	district_generator()
	areaing()
#	city_generate()
	redraw()

func retangle(wh,xy,t,b=false,bt=null):
	if ((b == false) and (wh.x > 1) and (wh.y > 1)):
		for x in range(wh.x):
			for y in range(wh.y):
				map_content[x+xy.x][y+xy.y] = t
		return (true)
	if ((b == true) and (wh.x > 2) and (wh.y > 2) and (typeof(bt)==TYPE_INT)):
		for x in range(wh.x-2):
			for y in range(wh.y-2):
				map_content[x+xy.x+1][y+xy.y+1] = t
		for x in range(wh.x):
			map_content[x+xy.x][0] = bt
			map_content[x+xy.x][wh.y+xy.y-1] = bt
		for y in range(wh.y):
			map_content[0][y+xy.y] = bt
			map_content[wh.x+xy.x-1][y+xy.y] = bt
		return (true)
	print("Error 2: Map is too small.")
	return (false)
func map_resize(size):
	map_content.clear()
	area.clear()
	area = {}
	for x in range(size.x):
		map_content.append([])
		for y in range(size.y):
			map_content[x].append(null)
	map_district.clear()
	distr_area.clear()
func redraw():
	clear()
	for x in range(map_size.x):
		for y in range(map_size.y):
			if (typeof(map_content[x][y])!=TYPE_INT):
				print("Error 1: No data at map cell. Occurs at cell " + str(x) +" " + str(y))
				return (false)
			set_cell(x,y,map_content[x][y])
	for x in range(map_size.x):
		for y in range(map_size.y):
			for i in map_district.keys():
				if map_district[i]["position"] == Vector2(x,y):
					distr.set_cell(x,y,map_district[i]["type"])
	for x in range(map_size.x):
		for y in range(map_size.y):
			for i in area.keys():
				if i == Vector2(x,y):
					distr_area.set_cell(x,y,area[i])
func district_generator():
	for i in range(15):
		var t
		if (round(randf())>=0.5):
			t = 3
		else:
			t = 4
		var e = true
		if (map_district.values().size()==0):
			var v = Vector2(round(rand_range(1,map_size.x-1)),round(rand_range(1,map_size.y-1)))
			make_district(v,t)
		else:
			for i in map_district.values():
				var v = Vector2(round(rand_range(1,map_size.x-1)),round(rand_range(1,map_size.y-1)))
				if (i==v):
					e = true
				else:
					make_district(v,t)
					e = false
					break
func make_district(position,type):
	map_district[str(map_district.size())] = {"position":position,"type":type}
func circle(pos,to_expand,t):
	if (area.has(pos)==false):
		if ((t != 5) or (t!=6)):
			area[pos] = t+2
	if ((area.has(Vector2(pos.x-1,pos.y))==false) and !(pos.x-1<0)):
		if ((t != 5) or (t!=6)):
			area[Vector2(pos.x-1,pos.y)] = t+2
		to_expand[Vector2(pos.x-1,pos.y)] = t
	if ((area.has(Vector2(pos.x,pos.y-1))==false) and !(pos.y-1<0)):
		if ((t != 5) or (t!=6)):
			area[Vector2(pos.x,pos.y-1)] = t+2
		to_expand[Vector2(pos.x,pos.y-1)] = t
	if ((area.has(Vector2(pos.x+1,pos.y))==false) and !(pos.x+1>map_size.x)):
		if ((t != 5) or (t!=6)):
			area[Vector2(pos.x+1,pos.y)] = t+2
		to_expand[Vector2(pos.x+1,pos.y)] = t
	if ((area.has(Vector2(pos.x,pos.y+1))==false) and !(pos.y+1>map_size.y)):
		if ((t != 5) or (t!=6)):
			area[Vector2(pos.x,pos.y+1)] = t+2
		to_expand[Vector2(pos.x,pos.y+1)] = t
func areaing():
	var to_expand={}
	var blokade = {}
	for i in map_district.values():
		to_expand[i["position"]] = i["type"]
	while(!to_expand.empty()):
		for i in to_expand.keys():
			print(to_expand)
			if (blokade.has(i)==false):
				circle(i,to_expand,to_expand[i])
				blokade[i]=null
				to_expand.erase(i)
			else:
				to_expand.erase(i)
func city_generate():
	retangle(map_size,Vector2(0,0),5,false,null)
	