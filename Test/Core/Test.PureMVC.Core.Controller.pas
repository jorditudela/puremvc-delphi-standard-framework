unit Test.PureMVC.Core.Controller;

interface

uses
  TestFramework,
  SysUtils,
  PureMVC.Interfaces.IController, PureMVC.Interfaces.IView,
  PureMVC.Interfaces.INotification,
  PureMVC.Interfaces.ICommand,
  PureMVC.Patterns.Command,
  PureMVC.Patterns.Notification,
  PureMVC.Utils,
  PureMVC.Core.Controller,
  PureMVC.Patterns.Observer;

type
  // Test methods for class TController

  TestTController = class(TTestCase)
  strict private
    FController: TController;
  private
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestExecuteCommand;
    procedure TestCommandIsNotRegistered;
    procedure TestRegisterCommand;
    procedure TestRemoveCommand;
    procedure TestInstanceIsNotNull;
  end;

implementation

type
  TTestableController = class(TController);
  TTestableCommand = class(TSimpleCommand)
  public
  const
    NAME = 'TestableCommand';
    procedure Execute(Notification: INotification);override;
  end;

  TControllerTestVO = class
  private
    FInput: integer;
    FResult: Integer;
  public
    constructor Create(Input: Integer);
    property Input: integer read FInput write FInput;
    property Result: Integer read FResult write FResult;
  end;

{ TTestableCommand }

procedure TTestableCommand.Execute(Notification: INotification);
var
  VO: TControllerTestVO;
begin
  VO := Notification.Body.AsType<TControllerTestVO>;
  VO.Result := VO.Input * 2;
end;

{ TControllerTestVO }

constructor TControllerTestVO.Create(Input: Integer);
begin
  inherited Create;
  FInput := Input;
end;

{ TestTController }

procedure TestTController.SetUp;
begin
  FController := TTestableController.Create;
end;

procedure TestTController.TearDown;
begin
  FreeAndNil(FController);
end;

procedure TestTController.TestInstanceIsNotNull;
var
  ReturnValue: IController;
begin
  ReturnValue := TController.Instance;
  CheckNotNull(ReturnValue, 'Controller.Instance is null');
end;

procedure TestTController.TestCommandIsNotRegistered;
begin
  CheckFalse(FController.HasCommand(TTestableCommand.NAME));
end;

procedure TestTController.TestRegisterCommand;
begin
  FController.RegisterCommand(TTestableCommand.NAME, TTestableCommand);
  CheckTrue(FController.HasCommand(TTestableCommand.NAME));
end;

procedure TestTController.TestRemoveCommand;
begin
  FController.RegisterCommand(TTestableCommand.NAME, TTestableCommand);
  FController.RemoveCommand(TTestableCommand.NAME);
  CheckFalse(FController.HasCommand(TTestableCommand.NAME));
end;

procedure TestTController.TestExecuteCommand;
var
  Note: INotification;
  VO: TControllerTestVO;
begin
  FController.RegisterCommand(TTestableCommand.NAME, TTestableCommand);
  VO := TControllerTestVO.Create(12);
  try
    Note := TNotification.Create(Self, TTestableCommand.NAME, VO, nil);
    FController.ExecuteCommand(Note);
    CheckEquals(24, VO.Result);
  finally
    VO.Free;
  end;
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TestTController.Suite);
end.
