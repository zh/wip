from waveapi import robot_abstract

def OnBlipSubmitted(properties, context):
  doc = context.GetBlipById(properties['blipId']).GetDocument()
  text = doc.GetText()
  if text.find('/createWave') == 0:
    _newWave       = robot_abstract.NewWave(context,                                                                                                                             context.GetRootWavelet().GetParticipants())
    _newWave.SetTitle("New Wave's Title")
    _newRootBlipId = _newWave.GetRootBlipId()
    _newRootBlip   = context.GetBlipById(_newRootBlipId)
    _newDocument   = _newRootBlip.GetDocument()
    _newDocument.AppendText("This is an additional Text") 
