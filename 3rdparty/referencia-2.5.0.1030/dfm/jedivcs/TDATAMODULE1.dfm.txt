object DataModule1: TDataModule1
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Left = 574
  Top = 286
  Height = 198
  Width = 283
  object AppSrvClient1: TAppSrvClient
    Server = 'localhost'
    Port = '2106'
    SocksAuthentication = socksNoAuthentication
    Answer = MWBuffer1
    MaxRetries = 0
    OnRequestDone = AppSrvClient1RequestDone
    OnSessionConnected = AppSrvClient1SessionConnected
    OnSessionClosed = AppSrvClient1SessionClosed
    OnBeforeSendRequest = AppSrvClient1BeforeSendRequest
    OnAfterSendRequest = AppSrvClient1AfterSendRequest
    Left = 24
    Top = 16
  end
  object MWBuffer1: TMWBuffer
    DataBufferSize = 2048
    HeaderSize = 0
    AutoExpand = 2048
    Left = 96
    Top = 16
  end
end
