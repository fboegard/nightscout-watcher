unit ufSettings;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
{$IFnDEF FPC}
  Windows,
{$ELSE}
  LCLIntf, LCLType,
{$ENDIF}
  uSettings, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin, ComCtrls, ExtCtrls;

type
  TOnUpdateCallerFormWithSettings = procedure of object;
  TOnTryLoadEntriesData = function: Boolean of object;

  { TfSettings }

  TfSettings = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    cbDrawSugarLevelDelta: TCheckBox;
    cbEnableGlucoseLevelAlarms: TCheckBox;
    cbEnableStaleDataAlarms: TCheckBox;
    gbGlucoseLevelAlarms: TGroupBox;
    Image1: TImage;
    lblHighGlucoseAlarm: TLabel;
    pc: TPageControl;
    seHighGlucoseAlarm: TSpinEdit;
    lblLowGlucoseAlarm: TLabel;
    seLowGlucoseAlarm: TSpinEdit;
    lblUrgentHighGlucoseAlarm: TLabel;
    seUrgentHighGlucoseAlarm: TSpinEdit;
    lblUrgentLowGlucoseAlarm: TLabel;
    seUrgentLowGlucoseAlarm: TSpinEdit;
    GroupBox2: TGroupBox;
    lblUrgentStaleDataAlarm: TLabel;
    seUrgentStaleDataAlarm: TSpinEdit;
    lblStaleDataAlarm: TLabel;
    seStaleDataAlarm: TSpinEdit;
    cbIsMmolL: TCheckBox;
    cbDrawHorzGuideLines: TCheckBox;
    cbDrawVertGuideLines: TCheckBox;
    cbDrawLastSugarLevel: TCheckBox;
    cbDrawLastSugarLevelDate: TCheckBox;
    cbDrawSugarExtremePoints: TCheckBox;
    cbDrawSugarLevel: TCheckBox;
    cbDrawSugarLines: TCheckBox;
    cbDrawSugarSlope: TCheckBox;
    cbShowCheckNewDataProgressBar: TCheckBox;
    cbShowWindowBorder: TCheckBox;
    seCheckInterval: TSpinEdit;
    seCountOfEntriesToRecive: TSpinEdit;
    lblCheckInterval: TLabel;
    lblCountOfEntriesToRecieve: TLabel;
    eNightscoutSite: TEdit;
    lblNightscoutSite: TLabel;
    sbScale: TScrollBar;
    lblScale: TLabel;
    lblAlphaBlend: TLabel;
    sbAlphaBlend: TScrollBar;
    lblMgDl: TLabel;
    lblMmolL: TLabel;
    lblUrgentHighGlucoseAlarmMmolL: TLabel;
    lblHighGlucoseAlarmMmolL: TLabel;
    lblLowGlucoseAlarmMmolL: TLabel;
    lblUrgentLowGlucoseAlarmMmolL: TLabel;
    cbDrawAlertLines: TCheckBox;
    lblTimeZoneCorrection: TLabel;
    seTimeZoneCorrection: TSpinEdit;
    cbDrawSugarLevelPoints: TCheckBox;
    tsAbout: TTabSheet;
    tsMain: TTabSheet;
    tsVisual: TTabSheet;
    tsAlerts: TTabSheet;
    procedure btnOKClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure DoChange(Sender: TObject);
    procedure DoGlucoseAlarmChange(Sender: TObject);
  private
    OldSettings: TSettings;
    TmpSettings: TSettings;
    NewSettings: TSettings;
    OnUpdateCallerFormWithSettings: TOnUpdateCallerFormWithSettings;
    OnTryLoadEntriesData: TOnTryLoadEntriesData;
    procedure AssignSettingsToComponents();
    procedure AssignComponentsToSettings;
    procedure AssignGlucoseAlertInMmolL(SpinEdit: TSpinEdit);
  public
    class function ShowForm(AOwner: TComponent; Settings: TSettings;
      OnUpdateCallerFormWithSettings: TOnUpdateCallerFormWithSettings;
      OnTryLoadEntriesData: TOnTryLoadEntriesData): Boolean;
    constructor CreateSpecial(AOwner: TComponent; Settings: TSettings);
    procedure AssignComponentsOnChangeEvent;
  end;

implementation

uses
  uNightscout;

{$R *.lfm}

{ TfSettings }

procedure TfSettings.btnOKClick(Sender: TObject);
begin
  AssignComponentsToSettings();
  OldSettings.Assign(NewSettings);
  
  if (NewSettings.NightscoutUrl <> OldSettings.NightscoutUrl) and
    Assigned(OnTryLoadEntriesData) and not OnTryLoadEntriesData then
  begin
    ModalResult := mrNone;
    Exit;
  end;
end;

constructor TfSettings.CreateSpecial(AOwner: TComponent; Settings: TSettings);
begin
  inherited Create(AOwner);
  OldSettings := Settings;
  NewSettings := Settings.Clone;
  TmpSettings := Settings.Clone;
  AssignSettingsToComponents();
  AssignComponentsOnChangeEvent();
  pc.ActivePage := tsMain;
  if Assigned(OnUpdateCallerFormWithSettings) then
    OnUpdateCallerFormWithSettings;
end;

procedure TfSettings.AssignComponentsOnChangeEvent;
begin
  cbEnableGlucoseLevelAlarms.OnClick := DoChange;
  cbEnableStaleDataAlarms.OnClick := DoChange;
  cbIsMmolL.OnClick := DoChange;

  seHighGlucoseAlarm.OnChange := DoGlucoseAlarmChange;
  seLowGlucoseAlarm.OnChange := DoGlucoseAlarmChange;
  seUrgentHighGlucoseAlarm.OnChange := DoGlucoseAlarmChange;
  seUrgentLowGlucoseAlarm.OnChange := DoGlucoseAlarmChange;
  sbScale.OnChange := DoChange;
  sbAlphaBlend.OnChange := DoChange;
  seTimeZoneCorrection.OnChange := DoChange;
  seStaleDataAlarm.OnChange := DoChange;
  seUrgentStaleDataAlarm.OnChange := DoChange;

  cbShowCheckNewDataProgressBar.OnClick := DoChange;
  cbDrawHorzGuideLines.OnClick := DoChange;
  cbDrawLastSugarLevel.OnClick := DoChange;
  cbDrawLastSugarLevelDate.OnClick := DoChange;
  cbDrawSugarExtremePoints.OnClick := DoChange;
  cbDrawSugarLevel.OnClick := DoChange;
  cbDrawSugarLines.OnClick := DoChange;
  cbDrawSugarSlope.OnClick := DoChange;
  cbDrawVertGuideLines.OnClick := DoChange;
  cbShowWindowBorder.OnClick := DoChange;
  cbDrawAlertLines.OnClick := DoChange;
  cbDrawSugarLevelPoints.OnClick := DoChange;
  cbDrawSugarLevelDelta.OnClick := DoChange;
end;

procedure TfSettings.FormDestroy(Sender: TObject);
begin
  FreeAndNil(NewSettings);
  FreeAndNil(TmpSettings);
end;

procedure TfSettings.AssignGlucoseAlertInMmolL(SpinEdit: TSpinEdit);
var
  i: Integer;
  Component: TControl;
begin
  for i := 0 to gbGlucoseLevelAlarms.ControlCount - 1 do
  begin
    Component := gbGlucoseLevelAlarms.Controls[i];
    if not (Component is TLabel) then
      Continue;

    if Component.Tag = SpinEdit.Tag then
    begin
      TLabel(Component).Caption := TNightscoutEntry.GetSugarStr(SpinEdit.Value, True);
      Break;
    end;
  end;
end;

procedure TfSettings.DoGlucoseAlarmChange(Sender: TObject);
begin
  AssignGlucoseAlertInMmolL(TSpinEdit(Sender));
  DoChange(Sender);
end;

procedure TfSettings.DoChange(Sender: TObject);
begin
  AssignComponentsToSettings();
  OldSettings.Assign(NewSettings);
  if Assigned(OnUpdateCallerFormWithSettings) then
    OnUpdateCallerFormWithSettings;
end;

procedure TfSettings.AssignSettingsToComponents;
begin
  cbDrawHorzGuideLines.Checked := NewSettings.IsInDrawStage(dsHorzGuideLines);
  cbDrawLastSugarLevel.Checked := NewSettings.IsInDrawStage(dsLastSugarLevel);
  cbDrawLastSugarLevelDate.Checked := NewSettings.IsInDrawStage(dsLastSugarLevelDate);
  cbDrawSugarExtremePoints.Checked := NewSettings.IsInDrawStage(dsSugarExtremePoints);
  cbDrawSugarLevel.Checked := NewSettings.IsInDrawStage(dsSugarLevel);
  cbDrawSugarLines.Checked := NewSettings.IsInDrawStage(dsSugarLines);
  cbDrawSugarSlope.Checked := NewSettings.IsInDrawStage(dsSugarSlope);
  cbDrawVertGuideLines.Checked := NewSettings.IsInDrawStage(dsVertGuideLines);
  cbDrawAlertLines.Checked := NewSettings.IsInDrawStage(dsAlertLines);
  cbDrawSugarLevelPoints.Checked := NewSettings.IsInDrawStage(dsSugarLevelPoints);
  cbDrawSugarLevelDelta.Checked := NewSettings.IsInDrawStage(dsSugarLevelDelta);

  cbEnableGlucoseLevelAlarms.Checked := NewSettings.EnableGlucoseLevelAlarms;
  cbEnableStaleDataAlarms.Checked := NewSettings.EnableStaleDataAlarms;
  cbIsMmolL.Checked := NewSettings.IsMmolL;
  cbShowCheckNewDataProgressBar.Checked := NewSettings.ShowCheckNewDataProgressBar;
  cbShowWindowBorder.Checked := NewSettings.ShowWindowBorder;
  sbAlphaBlend.Position := NewSettings.AlphaBlendValue;
  sbScale.Max := Length(cDrawStageSizes[1]);
  sbScale.Position := NewSettings.ScaleIndex;
  seCheckInterval.Value := NewSettings.CheckInterval;
  seCountOfEntriesToRecive.Value := NewSettings.CountOfEntriesToRecive;
  seHighGlucoseAlarm.Value := NewSettings.HighGlucoseAlarm;
  seLowGlucoseAlarm.Value := NewSettings.LowGlucoseAlarm;
  seStaleDataAlarm.Value := NewSettings.StaleDataAlarm;
  seUrgentHighGlucoseAlarm.Value := NewSettings.UrgentHighGlucoseAlarm;
  seUrgentLowGlucoseAlarm.Value := NewSettings.UrgentLowGlucoseAlarm;
  seUrgentStaleDataAlarm.Value := NewSettings.UrgentStaleDataAlarm;
  seTimeZoneCorrection.Value := NewSettings.TimeZoneCorrection;
  eNightscoutSite.Text := NewSettings.NightscoutUrl;

  AssignGlucoseAlertInMmolL(seUrgentHighGlucoseAlarm);
  AssignGlucoseAlertInMmolL(seHighGlucoseAlarm);
  AssignGlucoseAlertInMmolL(seLowGlucoseAlarm);
  AssignGlucoseAlertInMmolL(seUrgentLowGlucoseAlarm);
end;

procedure TfSettings.AssignComponentsToSettings;
begin
  NewSettings.CheckInterval := seCheckInterval.Value;
  NewSettings.CountOfEntriesToRecive := seCountOfEntriesToRecive.Value;

  NewSettings.HighGlucoseAlarm := seHighGlucoseAlarm.Value;
  NewSettings.LowGlucoseAlarm := seLowGlucoseAlarm.Value;
  NewSettings.UrgentHighGlucoseAlarm := seUrgentHighGlucoseAlarm.Value;
  NewSettings.UrgentLowGlucoseAlarm := seUrgentLowGlucoseAlarm.Value;
  NewSettings.IsMmolL := cbIsMmolL.Checked;
  NewSettings.StaleDataAlarm := seStaleDataAlarm.Value;
  NewSettings.UrgentStaleDataAlarm := seUrgentStaleDataAlarm.Value;
  NewSettings.EnableGlucoseLevelAlarms := cbEnableGlucoseLevelAlarms.Checked;
  NewSettings.EnableStaleDataAlarms := cbEnableStaleDataAlarms.Checked;

  NewSettings.SwitchDrawStage(dsHorzGuideLines, cbDrawHorzGuideLines.Checked);
  NewSettings.SwitchDrawStage(dsLastSugarLevel, cbDrawLastSugarLevel.Checked);
  NewSettings.SwitchDrawStage(dsLastSugarLevelDate, cbDrawLastSugarLevelDate.Checked);
  NewSettings.SwitchDrawStage(dsSugarExtremePoints, cbDrawSugarExtremePoints.Checked);
  NewSettings.SwitchDrawStage(dsSugarLevel, cbDrawSugarLevel.Checked);
  NewSettings.SwitchDrawStage(dsSugarLines, cbDrawSugarLines.Checked);
  NewSettings.SwitchDrawStage(dsSugarSlope, cbDrawSugarSlope.Checked);
  NewSettings.SwitchDrawStage(dsVertGuideLines, cbDrawVertGuideLines.Checked);
  NewSettings.SwitchDrawStage(dsAlertLines, cbDrawAlertLines.Checked);
  NewSettings.SwitchDrawStage(dsSugarLevelPoints, cbDrawSugarLevelPoints.Checked);
  NewSettings.SwitchDrawStage(dsSugarLevelDelta, cbDrawSugarLevelDelta.Checked);

  NewSettings.ShowCheckNewDataProgressBar := cbShowCheckNewDataProgressBar.Checked;
  NewSettings.ShowWindowBorder := cbShowWindowBorder.Checked;
  NewSettings.NightscoutUrl := eNightscoutSite.Text;

  NewSettings.ScaleIndex := sbScale.Position;
  NewSettings.AlphaBlendValue := sbAlphaBlend.Position;
  NewSettings.TimeZoneCorrection := seTimeZoneCorrection.Value;
end;

class function TfSettings.ShowForm(AOwner: TComponent; Settings: TSettings;
  OnUpdateCallerFormWithSettings: TOnUpdateCallerFormWithSettings;
  OnTryLoadEntriesData: TOnTryLoadEntriesData): Boolean;
var
  F: TfSettings;
begin
  F := TfSettings.CreateSpecial(AOwner, Settings);
  try
    F.OnUpdateCallerFormWithSettings := OnUpdateCallerFormWithSettings;
    F.OnTryLoadEntriesData := OnTryLoadEntriesData;
    Result := F.ShowModal = mrOk;
    if not Result then
      Settings.Assign(F.TmpSettings);
  finally
    FreeAndNil(F);
  end;
end;

end.
