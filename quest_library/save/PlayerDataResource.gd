extends Resource
class_name PlayerData

@export var inventory_data: Inventory_Data
@export var equip_helmet_data: Equip_Helmet_Data
@export var equip_body_data: Equip_Body_Data
@export var equip_weapon_data: Equip_Weapon_Data
@export var current_weapon_data: Gun_Data


@export var health:int = 16
@export var base_speed:float = 5
@export var run_speed:float = 10
@export var max_speed:Vector3 = Vector3(80,100000,80)
@export var air_speed: float = 5
@export var jump:float = 4
@export var rotation: Vector3
@export var camera_rotation: Vector3
@export var quest_value_list: Dictionary
