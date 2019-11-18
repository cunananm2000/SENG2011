// Data object for a blood packet
class BloodPacket
{
	var id :int;
	var bloodType:string;
	var donateDate:nat;
	var expiryDate:nat;

	constructor(given_id:int, bType:string, dDate: nat, eDate:nat)
	modifies this
	requires dDate < eDate;
	{
		this.id := given_id;
		this.bloodType := bType;
		this.donateDate := dDate;
		this.expiryDate := eDate;
	}

	function method IsExpired(currDate:nat) : bool
	reads this;
	{
		expiryDate <= currDate
	}

	function method IsNearExpiry(currDate:nat, bufferTime:nat) : bool
	reads this;
	{
		expiryDate + bufferTime <= currDate
	}
}

class BloodNotif
{
	var bloodPacket : BloodPacket;
	var status : string;

	constructor(bloodPacket:BloodPacket, status:string)
	requires status == "nearly expired" || status == "expired"
	modifies this
	{
		this.bloodPacket := bloodPacket;
		this.status := status;
	}
}

// TODO max size, buffTime and min levels setters 
class Vampire
{
	var inv : seq<BloodPacket>;
	var size : nat;
	var buffTime : nat;
	var bNotifs : seq<BloodNotif>;
	var currDate : nat;
	var currId : nat;

	predicate Valid()
	reads this, inv, bNotifs
	{
		|inv| <= size
		&& !exists j:nat :: j<|inv| && inv[j].id == currId
		&& forall i:nat :: i<|inv| ==> inv[i] != null && inv[i].IsExpired(currDate) ==>
			exists j:nat :: j<|bNotifs| && bNotifs[j] != null 
				&& bNotifs[j].bloodPacket == inv[i]
				&& bNotifs[j].status == "expired"
	}


	constructor()
	modifies this
	ensures Valid()
	{
		this.currId := 0;
		this.currDate := 0;
		this.size := 100;
		this.buffTime := 0;
		inv := [];
	}

	method makeDeposit(bType:string, dDate:nat, eDate:nat)
	modifies inv, this
	// requires bType
	requires Valid(); ensures Valid()
	requires dDate < eDate && eDate > currDate 
	ensures |old(inv)| == size ==> old(inv) == inv
	ensures |old(inv)| < size ==> 
		forall i:nat :: i<|old(inv)| && i<|inv| ==> old(inv[i]) == inv[i]
		&& inv[|inv|-1].id == currId && inv[|inv|-1].bloodType == bType
		&& inv[|inv|-1].donateDate == dDate && inv[|inv|-1].expiryDate == eDate
	{
		if (|inv| == size){
			return;
		}
		var b := new BloodPacket(currId, bType, dDate, eDate);
		inv := inv + [b];
		assert inv[..|inv|-1] == old(inv);
		currId := currId + 1;
		assert |old(inv)| < size ==> forall i:nat :: i<|old(inv)| && i<|inv| ==> old(inv[i]) == inv[i];
	}

	// Helper function which simply increments the date
	method tickTime()
	modifies this;
	{
		currDate := currDate + 1;
	}






}



