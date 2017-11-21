package DianShiTech.Protocal;
message EquipStrengthen {
  enum traits { value = 10057;}
  enum OpType{
    StrengthenOnce = 1;
	StrengthenNoLimit =2;
  }
  required int32 equip_id = 1;
  optional int32 op_type = 2;
}

