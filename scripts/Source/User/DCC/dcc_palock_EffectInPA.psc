Scriptname DCC:dcc_palock_EffectInPA extends ActiveMagicEffect
{monitors power armor equip status and removes power cores when you leave it.}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; vanilla forms.

ReferenceAlias Property PowerArmorRef Auto
{this is the PowerArmorRef from the PowerArmorRecallQuest which is the one
which tracks what power armor you last used and puts the pin on the map for
where you left it. as long as we use this it will only work for the player.}

Ammo Property AmmoFusionCore Auto
{the objects to remove from the power armor inventory.}

ObjectMod Property PA_FusionCore01 Auto
{the visual mod to remove from the powr armor frame.}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; mod options.

GlobalVariable Property PALockMode Auto
{1 = timed remove, 2 = distance remove.}

GlobalVariable Property PALockDelay Auto
{how long to wait (in seconds) before removing the core.}

GlobalVariable Property PALockDist Auto
{how far you have to wander (in meters) before removing the core.}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; state values.

Bool Property Near = FALSE Auto Hidden
{tracks if we have walked far enough to trigger a removal.}

Actor Property Me Auto Hidden
{tracks who did it. in this case the player.}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnEffectStart(Actor Target, Actor Caster)
{on power armor enter.}

	;;Debug.MessageBox("POWER UP")

	self.Near = TRUE
	self.Me = Target
	Return
EndEvent

Event OnEffectFinish(Actor Target, Actor Caster)
{on power armor exit.}

	;;Debug.MessageBox("POWER DOWN")~

	Int Mode = self.PALockMode.GetValueInt()
	ObjectReference PowerArmor = self.PowerArmorRef.GetReference()
	Float LockDistance

	self.Near = TRUE

	If(TRUE)
		PowerArmor.SetActorOwner(self.Me.GetActorBase(),FALSE)
	EndIf

	If(Mode == 1)
		;; do timed pull
		Utility.Wait(self.PALockDelay.GetValue())
		If(!self.Me.IsInPowerArmor())
			self.FusionCoreYoink(PowerArmor,self.Me)
		EndIf
	ElseIf(Mode == 2)
		;; do distance pull.
		LockDistance = self.PALockDist.GetValue() * 70
		While(self.Near && !self.Me.IsInPowerArmor())
			If(self.Me.GetDistance(PowerArmor) > LockDistance && !self.Me.IsInPowerArmor())
				self.FusionCoreYoink(PowerArmor,self.Me)
				self.Near = FALSE
			EndIf
			Utility.Wait(0.5)
		EndWhile
	EndIf

	Return
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function FusionCoreYoink(ObjectReference From, Actor Who)
{remove cores from the armor and give them to the actor.}

	From.RemoveItem(self.AmmoFusionCore,From.GetItemCount(self.AmmoFusionCore),FALSE,Who)
	;; transfer the fusion cores to you.

	From.RemoveMod(self.PA_FusionCore01)
	;; remove the visual core.

	Return
EndFunction
