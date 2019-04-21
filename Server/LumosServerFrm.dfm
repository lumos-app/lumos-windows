object LumosServerDlg: TLumosServerDlg
  Left = 0
  Top = 0
  Caption = 'LumosServerDlg'
  ClientHeight = 201
  ClientWidth = 447
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 24
    Top = 128
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 0
  end
  object Memo1: TMemo
    Left = 208
    Top = 16
    Width = 185
    Height = 129
    Lines.Strings = (
      'Memo1')
    TabOrder = 1
    WordWrap = False
  end
  object Button2: TButton
    Left = 24
    Top = 159
    Width = 91
    Height = 25
    Caption = 'Button2'
    TabOrder = 2
  end
end
