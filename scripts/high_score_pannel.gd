extends Sprite2D

var high_score: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	high_score = SaveManager.high_score
	$GoldMedal.hide()
	$SilverMedal.hide()
	$BronzeMedal.hide()
	$New.hide()
	hide()

func _hide() -> void:
	$GoldMedal.hide()
	$SilverMedal.hide()
	$BronzeMedal.hide()
	$New.hide()
	hide()

func _display(score: int) -> void:
	if score == 0:
		pass
	elif score >= high_score:
		$GoldMedal.show()
		if score > high_score:
			high_score = score
			$New.show()
	elif score > high_score - 5:
		$SilverMedal.show()
	elif score > high_score - 10:
		$BronzeMedal.show()
	$HighScore.text = str(high_score)
	$Score.text = str(score)
	show()
