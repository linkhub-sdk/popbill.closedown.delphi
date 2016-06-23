(*
*=================================================================================
* Unit for base module for Popbill API SDK. It include base functionality for
* RESTful web service request and parse json result. It uses Linkhub module
* to accomplish authentication APIs.
*
* http://www.popbill.com
* Author : Jeong Yohan (yhjeong@linkhub.co.kr)
* Written : 2015-07-01
* Thanks for your interest.
*=================================================================================
*)
unit PopbillClosedown;

interface

uses
        TypInfo,SysUtils,Classes,
        Popbill, Linkhub;
type
        TClosedownChargeInfo = class
        public
                unitCost : string;
                chargeMethod : string;
                rateSystem : string;
        end;
        
        TCorpState = class
        public
                corpNum : string;
                ctype : string;
                state : string;
                stateDate : string;
                checkDate : string;
        end;

        TCorpStateList = Array Of TCorpState;

        TClosedownService = class(TPopbillBaseService)
        private
                function jsonToTCorpState(json : String) : TCorpState;

        public
                constructor Create(LinkID : String; SecretKey : String);
                function GetUnitCost(CorpNum : String): Single;
                function checkCorpNum(CorpNum : String; UserCorpNum : String; UserID : String) : TCorpState;
                function checkCorpNums(CorpNumList : Array Of String; UserCorpNum : String; UserID : String) : TCorpStateList;
                function GetChargeInfo(CorpNum : String) : TClosedownChargeInfo;
        end;

implementation

constructor TClosedownService.Create(LinkID : String; SecretKey : String);
begin
       inherited Create(LinkID,SecretKey);
       AddScope('170');
end;

function TClosedownService.GetUnitCost(CorpNum : String) : Single;
var
        responseJson : string;
begin
        responseJson := httpget('/CloseDown/UnitCost',CorpNum,'');

        result := strToFloat(getJSonString( responseJson,'unitCost'));
end;


function TClosedownService.GetChargeInfo (CorpNum : string) : TClosedownChargeInfo;
var
        responseJson : String;
begin
        responseJson := httpget('/CloseDown/ChargeInfo',CorpNum,'');

        try
                result := TClosedownChargeInfo.Create;

                result.unitCost := getJSonString(responseJson, 'unitCost');
                result.chargeMethod := getJSonString(responseJson, 'chargeMethod');
                result.rateSystem := getJSonString(responseJson, 'rateSystem');

        except on E:Exception do
                raise EPopbillException.Create(-99999999,'결과처리 실패.[Malformed Json]');
        end;
end;



function TClosedownService.checkCorpNum(CorpNum : String; UserCorpNum : String; UserID : String) : TCorpState;
var
        responseJson : string;
        url : string;
begin
        if Length(corpNum) = 0 then
        begin
                raise EPopbillException.Create(-99999999, '사업자번호가 입력되지 않았습니다');
                Exit;
        end;

        url := '/CloseDown?CN='+ CorpNum;

        responseJson := httpget(url, UserCorpNum, UserID);

        result := jsonToTCorpState(responseJson);
end;


function TClosedownService.checkCorpNums(CorpNumList : Array Of String; UserCorpNum : String; UserID : String) : TCorpStateList;
var
        requestJson : string;
        responseJson : string;
        jSons : ArrayOfString;
        i : Integer;
begin
        if Length(CorpNumList) = 0 then
        begin
                raise EPopbillException.Create(-99999999, '사업자번호가 입력되지 않았습니다');
                Exit;
        end;

        requestJson := '[';
        for i:=0 to Length(CorpNumList) -1 do
        begin
                requestJson := requestJson + '"' + CorpNumList[i] + '"';
                if (i + 1) < Length(CorpNumList) then requestJson := requestJson + ',';
        end;

        requestJson := requestJson +']';

        responseJson := httppost('/CloseDown', UserCorpNum, UserID, requestJson);

        try
                jSons := ParseJsonList(responseJson);
                SetLength(result,Length(jSons));

                for i := 0 to Length(jSons)-1 do
                begin
                        result[i] := jsonToTCorpState(jSons[i]);
                end;

        except on E:Exception do
                raise EPopbillException.Create(-99999999, '결과처리 실패.[Malformed Json]');
        end;


end;

function TClosedownService.jsonToTCorpState(json : String) : TCorpState;
begin
        result := TCorpState.Create;

        if Length(getJsonString(json, 'corpNum')) > 0 then
        begin
                result.corpNum := getJsonString(json, 'corpNum');
        end;

        if Length(getJsonString(json, 'type')) > 0  then
        begin
                result.ctype := getJsonString(json, 'type');
        end;

        if Length(getJsonString(json, 'state')) > 0 then
        begin
                result.state := getJsonString(json, 'state');
        end;

        if Length(getJsonString(json, 'stateDate')) > 0  then
        begin
               result.stateDate := getJsonString(json, 'stateDate');
        end;

        if Length(getJsonString(json, 'checkDate')) > 0 then
        begin
              result.checkDate := getJsonString(json, 'checkDate');
        end;
end;


//End Of Unit.
end.
 