unit ufrmSplitCustomerOrder;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ufrmBasic, ActnList, ImgList, ComCtrls, ToolWin, ExtCtrls,
  DBGridEh, DB, ADODB, StdCtrls, Mask, DBCtrlsEh, DBLookupEh, DBCtrls,
  Buttons, uDMEntity, uDMManager;

type
  TfrmSplitCustomerOrder = class(TfrmBasic)
    dbedtOrderStates: TDBEditEh;
    Label14: TLabel;
    dbedtCustomerOrderID: TDBEditEh;
    Label10: TLabel;
    ds_active: TDataSource;
    gboxOriginalInfo: TGroupBox;
    Label8: TLabel;
    dbedtOrderNumber: TDBEditEh;
    dbedtOrderQty: TDBEditEh;
    Label6: TLabel;
    gboxNewInfo: TGroupBox;
    Label2: TLabel;
    edtOrderQty: TEdit;
    dbdtpRTD: TDBDateTimeEditEh;
    Label16: TLabel;
    chkRTD: TCheckBox;
    chkNewRTD: TCheckBox;
    Label3: TLabel;
    dtpRTD: TDateTimePicker;
    btnCancel: TBitBtn;
    btnOK: TBitBtn;
    procedure chkRTDClick(Sender: TObject);
    procedure chkNewRTDClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
  private
    { Private declarations }
    objCO: TCustomerOrder;
    objMgrCO: TMgrCustomerOrder;
  protected
    procedure InitializeForm; override;
    procedure DestoryForm; override;
    procedure SetUI; override;
  public
    { Public declarations }
    class function EdtFromList(adt_from: TADODataSet): Boolean;
  end;


implementation

uses DataModule, uMJ;

{$R *.dfm}

procedure TfrmSplitCustomerOrder.InitializeForm;
begin
  inherited;
  objCO := TCustomerOrder.Create;
  objMgrCO := TMgrCustomerOrder.Create;
end;

procedure TfrmSplitCustomerOrder.DestoryForm;
begin
  inherited;
  objCO.Free;
  objMgrCO.Free;
end;

procedure TfrmSplitCustomerOrder.SetUI;
begin
  Position := poOwnerFormCenter;
end;

class function TfrmSplitCustomerOrder.EdtFromList(adt_from: TADODataSet): Boolean;
begin
  with TfrmSplitCustomerOrder.Create(Application) do
  try
    if adt_from.RecordCount > 0 then
    begin
      ds_active.DataSet := adt_from;
      chkRTD.OnClick := nil;
      if adt_from.fieldbyname('RTD').AsString <> '' then
      begin
        chkRTD.Checked := true;
        chkNewRTD.Checked := true;
        dtpRTD.DateTime := dbdtpRTD.Value;
      end
      else
      begin
        chkRTD.Checked := false;
        dbdtpRTD.Value := null;
        chkNewRTD.Checked := true;
        dtpRTD.DateTime := now;
      end;
      chkRTD.OnClick := chkRTDClick;
    end;
    result := ShowModal = mrOk;
  finally
    Free;
  end;
end;

procedure TfrmSplitCustomerOrder.chkRTDClick(Sender: TObject);
begin
  if chkRTD.Checked then
  begin
    if not (dbdtpRTD.DataSource.DataSet.State in [dsEdit]) then
      dbdtpRTD.DataSource.DataSet.Edit;
    if dbdtpRTD.DataSource.DataSet.FieldByName('RTD').OldValue = null then
      dbdtpRTD.DataSource.DataSet.FieldByName('RTD').Value := now
    else
      dbdtpRTD.DataSource.DataSet.FieldByName('RTD').Value :=
        dbdtpRTD.DataSource.DataSet.FieldByName('RTD').OldValue;
  end
  else
  begin
    if not (dbdtpRTD.DataSource.DataSet.State in [dsEdit]) then
      dbdtpRTD.DataSource.DataSet.Edit;
    dbdtpRTD.DataSource.DataSet.FieldByName('RTD').Value := null;
  end;
end;

procedure TfrmSplitCustomerOrder.chkNewRTDClick(Sender: TObject);
begin
  if not chkRTD.Checked then
  begin
    dtpRTD.DateTime := null;
  end;
end;

procedure TfrmSplitCustomerOrder.btnOKClick(Sender: TObject);
var
  OrderQuantity, newOrderQty: integer;
  rtd: string;
begin
  OrderQuantity := ds_active.DataSet.FieldByName('CustomerOrderQuantity').AsInteger;
  newOrderQty := StrToInt(Trim(edtOrderQty.Text));

  if Trim(edtOrderQty.Text) = '' then
  begin
    ShowMessage('Please input new order qty.');
    ModalResult := mrNone;
    Exit;
  end
  else if Trim(edtOrderQty.Text) = '0' then
  begin
    ShowMessage('Order qty. can''t be 0.');
    ModalResult := mrNone;
    Exit;
  end
  else if Trim(edtOrderQty.Text) = IntToStr(OrderQuantity) then
  begin
    ShowMessage('Order qty. can''t same to original order qty.');
    ModalResult := mrNone;
    Exit;
  end
  else if StrToFloat(Trim(edtOrderQty.Text)) > OrderQuantity then
  begin
    ShowMessage('New order qty. can''t greater than original order qty.');
    ModalResult := mrNone;
    Exit;
  end; {
  else if FormatDateTime('YYYY-mm-dd', dbdtpRTD.Value) = FormatDateTime('YYYY-mm-dd', dtpRTD.DateTime) then
  begin
    ShowMessage('Order RTD can''t same to original order RTD.');
    ModalResult := mrNone;
    Exit;
  end; }
  if dtpRTD.DateTime <> null then
    rtd := FormatDateTime('YYYY-mm-dd', dtpRTD.DateTime)
  else
    rtd := '';
  objCO.CustomerOrderID := ds_active.DataSet.FieldByName('CustomerOrderID').AsInteger;
  objCO.CustomerOrderQuantity := OrderQuantity;
  objCO.Price := ds_active.DataSet.FieldByName('Price').AsFloat;
  objCO.RTD := rtd;
  objMgrCO.SplitCustomerOrder(objCO, newOrderQty);
end;


end.

