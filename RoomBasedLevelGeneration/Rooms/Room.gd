extends Node2D


var text = "Start" # only the text for the visualization

var neighbours_coords = [Vector2(0,-1),Vector2(0,1),Vector2(1,0),Vector2(-1,0)] # positon of the neighbours in grid
var walls = ["res://Rooms/Walls/WallTop.tscn","res://Rooms/Walls/WallBot.tscn","res://Rooms/Walls/WallR.tscn","res://Rooms/Walls/WallL.tscn"] # walls for top/bot/left/right
var wall_position= [Vector2(160,-16),Vector2(160,208),Vector2(336,88),Vector2(-16,88)] # position where walls may be placed

var itemroom = false
var bossroom = false
var startroom = false

var start_room = "res://Rooms/NormalRooms/1.tscn" # start room

var normal_rooms = ["res://Rooms/NormalRooms/1.tscn","res://Rooms/NormalRooms/1.tscn","res://Rooms/NormalRooms/1.tscn","res://Rooms/NormalRooms/1.tscn"] # you can use this array to store different rooms and place them randomly

var boss_rooms = ["res://Rooms/BossRooms/B1.tscn"] # see above, but with different Bossrooms

var current_room


func _ready():
	$Label.text = text # only sets the text for the visualization
	if startroom != true: # exec if the room is not the startroom
		randomize()
		var new_roomtype = load(normal_rooms[randi()% 4]).instance()
		add_child(new_roomtype)
		current_room = new_roomtype
	elif startroom == true: # exec if the room is the startroom
		var new_roomtype = load(start_room).instance()
		add_child(new_roomtype) 
		current_room = new_roomtype 
		
func last_room():
	$Label.text = "Boss" # only sets the text for the visualization
	bossroom = true
	current_room.queue_free()
	var new_roomtype = load(boss_rooms[randi()% 1]).instance()
	add_child(new_roomtype)
	current_room = new_roomtype
func item_room():
	$Label.text = "Item" # only sets the text for the visualization
	itemroom = true
	

func set_walls(): # set walls if there is no neighbour
	var coords = global_position / get_parent().room_size
	var rooms = get_parent().placed_rooms
	for i in neighbours_coords: # checks for neighbours
		var neigh = i+coords
		if neigh.x < 7 && neigh.y < 7: # checks if neighbours are inside the grid
			if rooms[neigh.y][neigh.x] == false: #
				if neighbours_coords.find(i) == 0: # Top Wall
					spawn_walls(0)
				if neighbours_coords.find(i) == 1: # Bottom Wall
					spawn_walls(1)
				if neighbours_coords.find(i) == 2: # Right Wall
					spawn_walls(2)
				if neighbours_coords.find(i) == 3: # Left Wall
					spawn_walls(3)
				
		else: # 
			if neighbours_coords.find(i) == 0: # Top Wall
				spawn_walls(0)
			if neighbours_coords.find(i) == 1: # Bottom Wall
				spawn_walls(1)
			if neighbours_coords.find(i) == 2: # Right Wall
				spawn_walls(2)
			if neighbours_coords.find(i) == 3: # Left Wall
				spawn_walls(3)
				
func spawn_walls(dir): # place walls at position 0-3 / dir contains the position
	var new_wall = load(walls[dir]).instance()
	new_wall.position = wall_position[dir]
	add_child(new_wall)
		
