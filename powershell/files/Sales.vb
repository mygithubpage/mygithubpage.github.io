Option Explicit

'--------------------------------------------------------------------------------------------------------------------------------------------------------------
'Excel Notice
'You Need to UnMerge the cell before you want to Merge the cell with other cell
'Always Add the sheet before the cell, not Cells() but Sheet.Cells()
'If an Error may occur then use On Error Resume Next and Assign the Variabe before you get the Variable from an expression
'Find the Column header Column instead of using the Column number directly, like Cells(,HeaderColumn) not Cells(,1)
'

''
'To Do
'1. Get File Date VBA.FileDateTime(ActiveSheet.Parent.FullName)
'2. Watch ReadWorkbook Delete Cell And Prompt to Delete the WriteWorkbook Cell
'--------------------------------------------------------------------------------------------------------------------------------------------------------------

Private Sub Initial()
    
    ThisWorkbook.Activate
    Dim WorksheetItem As Worksheet
    For Each WorksheetItem In Worksheets
        WorksheetItem.Activate
        If WorksheetItem.Name <> "P" Then
            Cells(1, 1).UnMerge
            Cells(1, 1).Value = UnicodeToCharacter("&H57FA&H672C&H4FE1&H606F")
            Range(Cells(1, 1), Cells(1, 2)).Merge
            Range(Cells(1, 1), Cells(1, 2)).HorizontalAlignment = xlCenter
            
            Cells(1, 3).UnMerge
            Cells(1, 3).Value = UnicodeToCharacter("&H7F6E&H4E1A&H987E&H95EE")
            Range(Cells(1, 3), Cells(1, 5)).Merge
            Range(Cells(1, 3), Cells(1, 5)).HorizontalAlignment = xlCenter
            
            Cells(1, 6).UnMerge
            Cells(1, 6).Value = UnicodeToCharacter("&H9500&H552E&H7ECF&H7406")
            Range(Cells(1, 6), Cells(1, 7)).Merge
            Range(Cells(1, 6), Cells(1, 7)).HorizontalAlignment = xlCenter
            
            Cells(1, 8).UnMerge
            Cells(1, 8).Value = UnicodeToCharacter("&H73B0&H573A&H7ECF&H7406")
            Range(Cells(1, 8), Cells(1, 9)).Merge
            Range(Cells(1, 8), Cells(1, 9)).HorizontalAlignment = xlCenter
            
            Cells(1, 10).UnMerge
            Cells(1, 10).Value = UnicodeToCharacter("&H7B56&H5212&H7ECF&H7406")
            Range(Cells(1, 10), Cells(1, 11)).Merge
            Range(Cells(1, 10), Cells(1, 11)).HorizontalAlignment = xlCenter
            
            Cells(1, 12).UnMerge
            Cells(1, 12).Value = UnicodeToCharacter("&H7B56&H5212&H5458 ")
            Range(Cells(1, 12), Cells(1, 13)).Merge
            Range(Cells(1, 12), Cells(1, 13)).HorizontalAlignment = xlCenter
            
            Cells(1, 14).UnMerge
            Cells(1, 14).Value = UnicodeToCharacter("&H5BA2&H670D  ")
            Range(Cells(1, 14), Cells(1, 15)).Merge
            Range(Cells(1, 14), Cells(1, 15)).HorizontalAlignment = xlCenter
            
            Cells(1, 16).UnMerge
            Cells(1, 16).Value = UnicodeToCharacter("&H5907&H6CE8")
            Range(Cells(1, 16), Cells(1, 17)).Merge
            Range(Cells(1, 16), Cells(1, 17)).HorizontalAlignment = xlCenter
            
            'To Do
            Cells(2, 1).Value = UnicodeToCharacter("&H623F&H53F7")
            Cells(2, 2).Value = UnicodeToCharacter("&H603B&H4EF7")
            
            Cells(2, 3).Value = UnicodeToCharacter("&H63D0&H62101")
            Cells(2, 4).Value = UnicodeToCharacter("&H63D0&H62102")
            Cells(2, 5).Value = UnicodeToCharacter("&H63D0&H62103")
            
            Cells(2, 6).Value = UnicodeToCharacter("&H63D0&H62101")
            Cells(2, 7).Value = UnicodeToCharacter("&H63D0&H62102")
            
            Cells(2, 8).Value = UnicodeToCharacter("&H63D0&H62101")
            Cells(2, 9).Value = UnicodeToCharacter("&H63D0&H62102")
            
            Cells(2, 10).Value = UnicodeToCharacter("&H63D0&H62101")
            Cells(2, 11).Value = UnicodeToCharacter("&H63D0&H62102")
            
            Cells(2, 12).Value = UnicodeToCharacter("&H63D0&H62101")
            Cells(2, 13).Value = UnicodeToCharacter("&H63D0&H62102")
            
            Cells(2, 14).Value = UnicodeToCharacter("&H63D0&H62101")
            Cells(2, 15).Value = UnicodeToCharacter("&H63D0&H62102")
            
            Cells(2, 16).Value = UnicodeToCharacter("&H5B9A&H8D2D&H65F6&H95F4")
            Cells(2, 17).Value = UnicodeToCharacter("&H63D0&H70B9")
            
            Cells(2, 18).ClearContents
            If WorksheetItem.Name = "18" Then
                Cells(2, 18).Value = UnicodeToCharacter("&H4E2D&H4ECB&H8D39")
            End If
        Else
            Cells(1, 1).Value = UnicodeToCharacter("&H8F66&H4F4D&H53F7")
            Cells(1, 2).Value = UnicodeToCharacter("&H603B&H4EF7")
            Cells(1, 3).Value = UnicodeToCharacter("&H7F6E&H4E1A&H987E&H95EE")
            Cells(1, 4).Value = UnicodeToCharacter("&H9500&H552E&H7ECF&H7406")
            Cells(1, 5).Value = UnicodeToCharacter("&H73B0&H573A&H7ECF&H7406")
            Cells(1, 6).Value = UnicodeToCharacter("&H7B56&H5212&H7ECF&H7406")
            Cells(1, 7).Value = UnicodeToCharacter("&H7B56&H5212&H5458 ")
            Cells(1, 8).Value = UnicodeToCharacter("&H5BA2&H670D  ")
            Cells(1, 9).Value = UnicodeToCharacter("&H5B9A&H8D2D&H65F6&H95F4")
            
        End If
        
        ActiveSheet.Columns.AutoFit
        
        
    Next WorksheetItem
End Sub

Private Sub ReadWholeWorkbookSheet()
    Dim WorkbookYear As Integer
    Dim ReadSheet As Worksheet
    'Dim ReadWorkbook As Workbook
    
    For WorkbookYear = 2016 To 2013 Step -3
        On Error Resume Next
        'ReadWorkbook = Workbooks(UnicodeToCharacter("&H9500&H552E&H63D0&H6210&H7ED3&H7B97&H8868(") & WorkbookYear & ").xlsx")
        For Each ReadSheet In Workbooks(UnicodeToCharacter("&H9500&H552E&H63D0&H6210&H7ED3&H7B97&H8868(") & WorkbookYear & ").xlsx").Sheets
        
            Call ReadNewSheet(ReadSheet)
            
        Next ReadSheet
    Next WorkbookYear
End Sub

Private Sub ReadNewSheet(ByRef ReadSheet As Worksheet)
    Dim MaxCol As Integer, MinCol As Integer, RowIter As Integer, ColIter As Integer, ReadSheetLastRow As Integer, ReadSheetLastCol As Integer
    
    Dim RoomId As String
    
    Dim ReadSheetCols As Collection, WriteSheetCols As Collection, Occupation As Collection, RWCells As New Collection
    
    Dim WriteSheet As Worksheet
    
    Dim RoomIdRow As Integer
    Dim Royalties As Double
   
    Dim ReadCell As Range, WriteCell As Range

    Set ReadSheetCols = GetReadSheetCols(ReadSheet)
    
    MinCol = ReadSheet.Cells.Rows(3).Find(What:=UnicodeToCharacter("&H63D0&H6210&H2460")).Column
    MaxCol = ReadSheet.Cells.Rows(3).Find(What:=UnicodeToCharacter("&H63D0&H6210&H2461"), SearchDirection:=xlPrevious).Column
    ReadSheetLastRow = ReadSheet.Cells(ReadSheet.Rows.Count, MaxCol).End(xlUp).Row
    ReadSheetLastCol = ReadSheet.Cells(4, ReadSheet.Columns.Count).End(xlToLeft).Column
    
    On Error Resume Next
    For RowIter = 4 To ReadSheetLastRow 'RowIter = 4 Start Row
        
        If ReadSheet.Cells(RowIter, ReadSheetCols(UnicodeToCharacter("RRoyaltiesCol")) <> "&H8F66&H4F4D") And Not IsEmpty(ReadSheet.Cells(RowIter, ReadSheetCols("RRoyaltiesCol"))) _
        And Left(ReadSheet.Cells(RowIter, ReadSheetCols("RRoomCol")), 1) <> "C" And Left(ReadSheet.Cells(RowIter, ReadSheetCols("RRoomCol")), 1) <> "-" Then
            
            Call UpdateCells(RWCells, ReadSheetCols, ReadSheet, "Read-NotParking", RowIter)
            
            Set ReadCell = ReadSheet.Cells(RowIter, ReadSheetCols("RBuildingCol"))
            
            RoomId = GetRoomId(ReadCell)
            
            Set WriteSheet = ThisWorkbook.Sheets(ReadSheet.Cells(RowIter, ReadSheetCols("RBuildingCol")) & "")
            
            Set WriteSheetCols = GetWriteSheetCols(WriteSheet)
            
            RoomIdRow = EnterRoomId(RoomId, WriteSheet)
            
            Call UpdateCells(RWCells, WriteSheetCols, WriteSheet, "Write-NotParking", RoomIdRow)
            
            Royalties = FillOnce(RWCells, ReadSheet.Cells(RowIter, ReadSheet.Cells(RowIter, ReadSheet.Columns.Count).End(xlToLeft).Column))
            
            For ColIter = MinCol To MaxCol

                Set ReadCell = ReadSheet.Cells(RowIter, ColIter)
                
                If Not IsEmpty(ReadCell) And IsNumeric(ReadCell) And MyRound(ReadCell) <> 0 Then

                    If Left(ReadSheet.Cells(3, ColIter), 2) = UnicodeToCharacter("&H63D0&H6210") Then
                        
                        Set Occupation = SelectOccupation(ReadSheet, WriteSheetCols, ColIter, RWCells("RBookTimeCell"), Royalties)
                        
                        Set WriteCell = WriteSheet.Cells(RoomIdRow, Occupation("RoomIdCol"))
                        
                        Call CheckError(ReadCell, WriteCell, RWCells("RTotalPriceCell"), Occupation, ReadSheet)
                        
                        Call FillCell(ReadCell, WriteCell)
                        
                    End If
                End If
            Next ColIter
            
         ElseIf ReadSheet.Cells(RowIter, ReadSheetCols(UnicodeToCharacter("RRoyaltiesCol")) = "&H8F66&H4F4D") Or Left(ReadSheet.Cells(RowIter, ReadSheetCols("RRoomCol")), 1) = "C" Or _
         Left(ReadSheet.Cells(RowIter, ReadSheetCols("RRoomCol")), 1) = "-" Then
            'If IsEmpty(ReadSheet.Cells(RowIter, ReadSheetCols("RBuildingCol"))) Then Exit For
            
            Set WriteSheet = ThisWorkbook.Sheets("P")
            
            Set WriteSheetCols = GetWriteSheetCols(WriteSheet)
            RoomId = ReadSheet.Cells(RowIter, ReadSheetCols("RRoomCol"))
            RoomIdRow = EnterRoomId(RoomId, WriteSheet)
            
            Call UpdateCells(RWCells, ReadSheetCols, ReadSheet, "Read-Parking", RowIter)
            Call UpdateCells(RWCells, WriteSheetCols, WriteSheet, "Write-Parking", RoomIdRow)
            
            RWCells("RBookTimeCell") = Split(ReadSheet.Name, ".")(0)
            RWCells("RBookTimeCell").Offset(0, 1) = Split(ReadSheet.Name, ".")(1)
            Royalties = FillOnce(RWCells, ReadSheet.Cells(RowIter, ReadSheet.Cells(RowIter, ReadSheet.Columns.Count).End(xlToLeft).Column))
                   
                   
            For ColIter = ReadSheet.Cells.Rows(3).Find(What:=UnicodeToCharacter("&H63D0&H6210&H2460")).Column To MaxCol
            
                Set ReadCell = ReadSheet.Cells(RowIter, ColIter)
                
                If Not IsEmpty(ReadCell) And IsNumeric(ReadCell) Then
                        
                    'Set False first, If it is right then remove the Background Color
                    Set Occupation = SelectOccupation(ReadSheet, WriteSheetCols, ColIter, RWCells("RBookTimeCell"), Royalties)
                    
                    Set WriteCell = WriteSheet.Cells(RoomIdRow, Occupation("RoomIdCol"))
                    
                    Call CheckError(ReadCell, WriteCell, RWCells("RTotalPriceCell"), Occupation, ReadSheet)
                            
                    Call FillCell(ReadCell, WriteCell)
                End If
            Next ColIter
        End If
    
    Next RowIter
    
End Sub

Private Sub ReadOldSheet()

    'Dim WorkBookName As String
    'Dim WorkSheetName As String
    
    Dim RoomId As String
    Dim RoomIdRow As Integer
    Dim RoomIdColumn As Integer
    
    Dim RoomIdLocation As Range
    Dim RoomOffset As String

    Dim ReadSheet As Worksheet
    Dim WriteSheet As Worksheet
    Dim SourceSheet As Worksheet
    
    Dim ReadSheetLastRow As Integer
    Dim ReadSheetLastColumn As Integer
    
    Dim WriteSheetLastRow As Integer 'Write Sheet Row
    
    
    Dim SheetNum As Integer
    SheetNum = 2

    Set ReadSheet = Workbooks(UnicodeToCharacter("&H4EE3&H7406&H8D39&H652F&H4ED8&H60C5&H51B5&H8868.xlsx")).Sheets(SheetNum & "")
    Set WriteSheet = ThisWorkbook.Worksheets(SheetNum & "")
    
    If False Then
    
                ReadSheet.Hyperlinks.Add Anchor:=ReadCell, _
                Address:=Workbooks(WriteSheet.Parent.Name).FullName, _
                SubAddress:=WriteSheet.Name, _
                ScreenTip:=WriteSheet.Name
                WriteSheet.Columns.AutoFit
    End If
    ReadSheetLastColumn = ReadSheet.Cells(1, ReadSheet.Columns.Count).End(xlToLeft).Column
    ReadSheetLastRow = ReadSheet.Cells(ReadSheet.Rows.Count, 1).End(xlUp).Row
    '& "!" & WriteCell.Address
    Dim RowItem As Integer
    Dim ColumnItem As Integer
    
    Dim Percentage As String
    Dim Payment As Long
    
    Set RoomIdLocation = ReadSheet.Cells(1, 1)
    If ReadSheet.Rows(1).Find(What:=UnicodeToCharacter("&H623F&H53F7"), After:=RoomIdLocation.Offset(0, 1)).Column = 1 Then
        RoomOffset = ReadSheetLastColumn
    Else
        RoomOffset = ReadSheet.Rows(1).Find(What:=UnicodeToCharacter("&H623F&H53F7"), After:=RoomIdLocation.Offset(0, 1)).Column - RoomIdLocation.Column
    End If
 
    Do
        WriteSheetLastRow = WriteSheet.Cells(Rows.Count, 1).End(xlUp).Row
        
        For RowItem = 2 To ReadSheetLastRow
            
            RoomId = ReadSheet.Cells(RowItem, RoomIdLocation.Column).Value
            If Not IsEmpty(RoomId) Then
                RoomIdRow = 0
                On Error Resume Next
                RoomIdRow = WriteSheet.Cells.Find(What:=RoomId, SearchOrder:=xlByRows).Row
                
                If RoomIdRow = 0 Then
                    EnterRoom (RoomId)
                End If
                
                For ColumnItem = RoomIdLocation.Column + 2 To RoomIdLocation.Column + RoomOffset - 1
          
                    If Not IsEmpty(ReadSheet.Cells(RowItem, ColumnItem)) And ReadSheet.Cells(RowItem, ColumnItem) > 0 Then
 
                        Percentage = ReadSheet.Cells(1, ColumnItem)
                        Payment = MyRound(ReadSheet.Cells(RowItem, RoomIdLocation.Column + 1) * Val(Mid(Percentage, 7, 8)) * Left(Percentage, 4) * 0.0001)
                        RoomIdColumn = 0
                        
                        SheetNum = FindSource(RoomId, Percentage, Payment, WriteSheet.Cells(RoomIdRow, RoomIdColumn))
                        Select Case Mid(Percentage, 7, 8)
                        Case "80%":
                            Select Case Left(Percentage, 4)
                            Case 0.06:
                                If ReadSheet.Cells(RowItem, ColumnItem) = Payment Then
                                    RoomIdColumn = 6
                                Else
                                    ReadSheet.Cells(RowItem, ColumnItem).Interior.Color = vbYellow
                                End If
                            Case 0.05
                                If ReadSheet.Cells(RowItem, ColumnItem) = Payment Then
                                    WriteSheet.Cells(RoomIdRow, 8).Value = Payment
                                Else
                                    SheetNum = AddHyperLink(ReadSheet, ReadSheet.Cells(RowItem, ColumnItem), RoomId, Payment)
                                End If
                            Case 0.01:
                                If ReadSheet.Cells(RowItem, ColumnItem) = Payment Then
                                    WriteSheet.Cells(RoomIdRow, 10).Value = Payment
                                Else
                                    SheetNum = AddHyperLink(ReadSheet, ReadSheet.Cells(RowItem, ColumnItem), RoomId, Payment)
                                End If
                            Case 0.03:
                                If ReadSheet.Cells(RowItem, ColumnItem) = Payment Then
                                    WriteSheet.Cells(RoomIdRow, 15).Value = Payment
                                Else
                                    SheetNum = AddHyperLink(ReadSheet, ReadSheet.Cells(RowItem, ColumnItem), RoomId, Payment)
                                End If
                                
                            End Select
                        Case "20%":
                            Select Case Left(Percentage, 4)
                            Case 0.06:
                                If ReadSheet.Cells(RowItem, ColumnItem) = Payment Then
                                    WriteSheet.Cells(RoomIdRow, 7).Value = Payment
                                Else
                                    SheetNum = AddHyperLink(ReadSheet, ReadSheet.Cells(RowItem, ColumnItem), RoomId, Payment)
                                End If
                            Case 0.05:
                                If ReadSheet.Cells(RowItem, ColumnItem) = Payment Then
                                    WriteSheet.Cells(RoomIdRow, 9).Value = Payment
                                Else
                                    SheetNum = AddHyperLink(ReadSheet, ReadSheet.Cells(RowItem, ColumnItem), RoomId, Payment)
                                End If
                            Case 0.01:
                                If ReadSheet.Cells(RowItem, ColumnItem) = Payment Then
                                    WriteSheet.Cells(RoomIdRow, 11).Value = Payment
                                Else
                                    SheetNum = AddHyperLink(ReadSheet, ReadSheet.Cells(RowItem, ColumnItem), RoomId, Payment)
                                End If
                            Case Is > 0.07:
                                If ReadSheet.Cells(RowItem, ColumnItem) = Payment Then
                                    WriteSheet.Cells(RoomIdRow, 5).Value = Payment
                                Else
                                    SheetNum = AddHyperLink(ReadSheet, ReadSheet.Cells(RowItem, ColumnItem), RoomId, Payment)
                                End If
                            End Select
 
                        Case "50%":
                            If ReadSheet.Cells(RowItem, ColumnItem) = Payment Then
                                WriteSheet.Cells(RoomIdRow, 3).Value = Payment
                            Else
                                SheetNum = AddHyperLink(ReadSheet, ReadSheet.Cells(RowItem, ColumnItem), RoomId, Payment)
                            End If
                            
                        Case "45%", "30%":
                            If ReadSheet.Cells(RowItem, ColumnItem) = Payment Then
                                WriteSheet.Cells(RoomIdRow, 4).Value = Payment
                            Else
                                SheetNum = AddHyperLink(ReadSheet, ReadSheet.Cells(RowItem, ColumnItem), RoomId, Payment)
                            End If
                            
                        Case "5%":
                            If ReadSheet.Cells(RowItem, ColumnItem) = Payment Then
                                WriteSheet.Cells(RoomIdRow, 5).Value = Payment
                            Else
                                SheetNum = AddHyperLink(ReadSheet, ReadSheet.Cells(RowItem, ColumnItem), RoomId, Payment)
                            End If
                        End Select
                        
                        SheetNum = AddHyperLink(ReadSheet, ReadSheet.Cells(RowItem, ColumnItem), RoomId, Payment)
                        
                        If RoomIdColumn <> 0 Then
                            WriteSheet.Cells(RoomIdRow, RoomIdColumn).Value = Payment
                        Else
                            
                        End If
                        
                    End If
                Next ColumnItem

            End If
        Next RowItem
        
        Set RoomIdLocation = ReadSheet.Rows(1).Find(What:=UnicodeToCharacter("&H623F&H53F7"), After:=RoomIdLocation.Offset(0, 1))
    Loop Until RoomIdLocation.Address = ReadSheet.Cells(1, 1).Address
    
End Sub


Function GetReadSheetCols(ByVal ReadSheet As Worksheet)
    Dim ReadSheetCols As New Collection
    
    On Error Resume Next
    ReadSheetCols.Add Item:=ReadSheet.Rows(3).Find(What:=UnicodeToCharacter("&H680B&H53F7")).Column, Key:="RBuildingCol"
    ReadSheetCols.Add Item:=ReadSheet.Rows(3).Find(What:=UnicodeToCharacter("&H5355&H5143")).Column, Key:="RUnitCol"
    ReadSheetCols.Add Item:=ReadSheet.Rows(3).Find(What:=UnicodeToCharacter("&H623F&H53F7")).Column, Key:="RRoomCol"
    ReadSheetCols.Add Item:=ReadSheet.Rows(3).Find(What:=UnicodeToCharacter("&H603B&H4EF7")).Column, Key:="RTotalPriceCol"
    
    ReadSheetCols.Add Item:=ReadSheet.Rows(2).Find(What:=UnicodeToCharacter("&H7F6E&H4E1A&H987E&H95EE*")).Column, Key:="RPropertyConsultantCol"
    ReadSheetCols.Add Item:=ReadSheet.Rows(2).Find(What:=UnicodeToCharacter("&H9500&H552E&H7ECF&H7406*")).Column, Key:="RSalesManagerCol"
    ReadSheetCols.Add Item:=ReadSheet.Rows(2).Find(What:=UnicodeToCharacter("&H73B0&H573A&H7ECF&H7406*")).Column, Key:="RSiteManagerCol"
    ReadSheetCols.Add Item:=ReadSheet.Rows(2).Find(What:=UnicodeToCharacter("&H7B56&H5212&H7ECF&H7406*")).Column, Key:="RPlanningManagerCol"
    ReadSheetCols.Add Item:=ReadSheet.Rows(2).Find(What:=UnicodeToCharacter("&H7B56&H5212&H5458*")).Column, Key:="RPlannerCol"
    ReadSheetCols.Add Item:=ReadSheet.Rows(2).Find(What:=UnicodeToCharacter("&H5BA2&H670D*")).Column, Key:="RCustomServiceCol"
    
    ReadSheetCols.Add Item:=ReadSheet.Rows(2).Find(What:=UnicodeToCharacter("*&H8D2D*")).Column, Key:="RBookTimeCol"    '----------------&H5B9A&H8D2D&H65F6&H95F4
    ReadSheetCols.Add Item:=ReadSheet.Rows(3).Find(What:=UnicodeToCharacter("*&H7F34&H6B3E&H60C5&H51B5")).Column, Key:="RRoyaltiesCol"
    Set GetReadSheetCols = ReadSheetCols
End Function

Function GetWriteSheetCols(ByVal WriteSheet As Worksheet)
    Dim WriteSheetCols As New Collection
    
    On Error Resume Next
    If WriteSheet.Name <> "P" Then
        WriteSheetCols.Add Item:=WriteSheet.Rows(2).Find(What:=UnicodeToCharacter("&H623F&H53F7")).Column, Key:="WRoomCol"
        WriteSheetCols.Add Item:=WriteSheet.Rows(2).Find(What:=UnicodeToCharacter("&H603B&H4EF7")).Column, Key:="WTotalPriceCol"
        
        WriteSheetCols.Add Item:=WriteSheet.Rows(1).Find(What:=UnicodeToCharacter("&H7F6E&H4E1A&H987E&H95EE")).Column, Key:="WPropertyConsultantCol"
        WriteSheetCols.Add Item:=WriteSheet.Rows(1).Find(What:=UnicodeToCharacter("&H9500&H552E&H7ECF&H7406")).Column, Key:="WSalesManagerCol"
        WriteSheetCols.Add Item:=WriteSheet.Rows(1).Find(What:=UnicodeToCharacter("&H73B0&H573A&H7ECF&H7406")).Column, Key:="WSiteManagerCol"
        WriteSheetCols.Add Item:=WriteSheet.Rows(1).Find(What:=UnicodeToCharacter("&H7B56&H5212&H7ECF&H7406")).Column, Key:="WPlanningManagerCol"
        WriteSheetCols.Add Item:=WriteSheet.Rows(1).Find(What:=UnicodeToCharacter("&H7B56&H5212&H5458")).Column, Key:="WPlannerCol"
        WriteSheetCols.Add Item:=WriteSheet.Rows(1).Find(What:=UnicodeToCharacter("&H5BA2&H670D")).Column, Key:="WCustomServiceCol"
        
        WriteSheetCols.Add Item:=WriteSheet.Rows(2).Find(What:=UnicodeToCharacter("&H5B9A&H8D2D&H65F6&H95F4")).Column, Key:="WBookTimeCol"
        WriteSheetCols.Add Item:=WriteSheet.Rows(2).Find(What:=UnicodeToCharacter("&H63D0&H70B9")).Column, Key:="WRoyaltiesCol"
    Else
        WriteSheetCols.Add Item:=WriteSheet.Rows(1).Find(What:=UnicodeToCharacter("&H623F&H53F7")).Column, Key:="WRoomCol"
        WriteSheetCols.Add Item:=WriteSheet.Rows(1).Find(What:=UnicodeToCharacter("&H603B&H4EF7")).Column, Key:="WTotalPriceCol"
        
        WriteSheetCols.Add Item:=WriteSheet.Rows(1).Find(What:=UnicodeToCharacter("&H7F6E&H4E1A&H987E&H95EE")).Column, Key:="WPropertyConsultantCol"
        WriteSheetCols.Add Item:=WriteSheet.Rows(1).Find(What:=UnicodeToCharacter("&H9500&H552E&H7ECF&H7406")).Column, Key:="WSalesManagerCol"
        WriteSheetCols.Add Item:=WriteSheet.Rows(1).Find(What:=UnicodeToCharacter("&H73B0&H573A&H7ECF&H7406")).Column, Key:="WSiteManagerCol"
        WriteSheetCols.Add Item:=WriteSheet.Rows(1).Find(What:=UnicodeToCharacter("&H7B56&H5212&H7ECF&H7406")).Column, Key:="WPlanningManagerCol"
        WriteSheetCols.Add Item:=WriteSheet.Rows(1).Find(What:=UnicodeToCharacter("&H7B56&H5212&H5458")).Column, Key:="WPlannerCol"
        WriteSheetCols.Add Item:=WriteSheet.Rows(1).Find(What:=UnicodeToCharacter("&H5BA2&H670D")).Column, Key:="WCustomServiceCol"
        
        WriteSheetCols.Add Item:=WriteSheet.Rows(1).Find(What:=UnicodeToCharacter("&H5B9A&H8D2D&H65F6&H95F4")).Column, Key:="WBookTimeCol"
        WriteSheetCols.Add Item:=WriteSheet.Rows(1).Find(What:=UnicodeToCharacter("&H63D0&H70B9")).Column, Key:="WRoyaltiesCol"
    End If
    Set GetWriteSheetCols = WriteSheetCols
End Function

Function GetRoomId(ByRef ReadCell As Range)
     Dim RoomId As String
     'ReadCell is Building Cell
     'ReadCell.Offset(0,1) is Unit Cell
     'ReadCell.Offset(0,2) is Room Cell
    'If IsEmpty(ReadCell) Then Exit For
    'Get RoomId Col then combine the Content
    '------------------------------------------------------

    'Made the 3 digit RoomId to 4 digit RoomId by adding a 0 prefix, like 902 to 0902
    If Len(ReadCell.Offset(0, 2)) = 3 And ReadCell.Offset(3 - ReadCell.Row, 2) = UnicodeToCharacter("&H623F&H53F7") Then
        ReadCell.Offset(0, 2).NumberFormat = "@"
        ReadCell.Offset(0, 2) = "0" & ReadCell.Offset(0, 2)
    End If
    
    'No Unit Col or the Col has content then omit Unit in RoomId
    If IsEmpty(ReadCell.Offset(0, 1)) And ReadCell.Offset(3 - ReadCell.Row, 2) = UnicodeToCharacter("&H623F&H53F7") Then
        RoomId = ReadCell & "-" & ReadCell.Offset(0, 2)
    ElseIf Not IsEmpty(ReadCell.Offset(0, 1)) And ReadCell.Offset(3 - ReadCell.Row, 2) = UnicodeToCharacter("&H623F&H53F7") Then
        RoomId = ReadCell & "-" & ReadCell.Offset(0, 1) & "-" & ReadCell.Offset(0, 2)
    ElseIf Not IsEmpty(ReadCell.Offset(0, 1)) And ReadCell.Offset(3 - ReadCell.Row, 1) = UnicodeToCharacter("&H623F&H53F7") Then
        RoomId = ReadCell & "-" & ReadCell.Offset(0, 1)
    End If
    '------------------------------------------------------
    GetRoomId = RoomId
End Function

Function EnterRoomId(ByVal RoomId As String, ByRef WriteSheet As Worksheet)
    Dim RoomIdRow As Integer
    Dim ReadSheetLastRow As Integer
    Dim WriteSheetLastRow As Integer
    Dim WriteSheetLastCol As Integer
    
    Dim hl As Hyperlink
    Dim ReadSheet As Worksheet
    
    WriteSheetLastRow = WriteSheet.Cells(WriteSheet.Rows.Count, 1).End(xlUp).Row
    'ReadSheetLastRow = ReadSheet.Cells(ReadSheet.Rows.Count, 1).End(xlUp).Row
    'WriteSheetLastCol = ReadSheet.Cells(2, WriteSheet.Columns.Count).End(xlToLeft).Column
    
    On Error Resume Next
    RoomIdRow = 0 'Initial the value every row, If you do not do that, it will use last value if it can not be found
    RoomIdRow = WriteSheet.Columns(1).Find(What:=RoomId).Row

    If RoomIdRow = 0 Then
        WriteSheet.Cells(WriteSheetLastRow + 1, 1).NumberFormat = "@"
        WriteSheet.Cells(WriteSheetLastRow + 1, 1) = RoomId
        WriteSheetLastRow = WriteSheetLastRow + 1
        
        If WriteSheet.Name <> "P" Then
            WriteSheetLastCol = WriteSheet.Cells(2, WriteSheet.Columns.Count).End(xlToLeft).Column
            WriteSheet.Range(WriteSheet.Cells(3, 1), WriteSheet.Cells(WriteSheetLastRow, WriteSheetLastCol)).Sort Key1:=Cells(3, 1), Order1:=xlAscending
        Else
            WriteSheetLastCol = WriteSheet.Cells(1, WriteSheet.Columns.Count).End(xlToLeft).Column
            WriteSheet.Range(WriteSheet.Cells(2, 1), WriteSheet.Cells(WriteSheetLastRow, WriteSheetLastCol)).Sort Key1:=Cells(2, 1), Order1:=xlAscending
        End If
        
        RoomIdRow = WriteSheet.Columns(1).Find(What:=RoomId).Row
        
        For Each hl In WriteSheet.Hyperlinks
            With hl
                If .Range.Row >= RoomIdRow Then
                    On Error Resume Next
                    Set ReadSheet = Workbooks(Split(hl.ScreenTip, "!")(0) & "").Sheets(Split(hl.ScreenTip, "!")(1) & "")
                    If ReadSheet Is Nothing Then
                        Set ReadSheet = Workbooks.Open(FileName:=Split(hl.ScreenTip, "!")(0) & "").Sheets(Split(hl.ScreenTip, "!")(1) & "")
                    End If
                    
                    ReadSheet.Range(Split(hl.ScreenTip, "!")(2) & "").Hyperlinks(1).SubAddress = WriteSheet.Name & "!" & hl.Range.Address
                    ReadSheet.Range(Split(hl.ScreenTip, "!")(2) & "").Hyperlinks(1).ScreenTip = WriteSheet.Name & "!" & hl.Range.Address
                End If
            End With
        Next hl
    End If
    EnterRoomId = RoomIdRow
    
End Function

Function FillOnce(ByRef RWCells As Collection, ByVal LastCell As Range)
    
    Dim Royalties As Double
    
    If IsEmpty(RWCells("WTotalPriceCell")) Then RWCells("WTotalPriceCell") = Format(RWCells("RTotalPriceCell"), "#.##0")
    
    If IsEmpty(RWCells("WBookTimeCell")) Then
        RWCells("WBookTimeCell").NumberFormat = "@"
        On Error Resume Next
        If Len(RWCells("RRoyaltiesCell")) > 6 Then               '------------------------ReadSheetCols("RBookTimeCol") = 0 Or
            RWCells("WBookTimeCell") = Left(RWCells("RRoyaltiesCell"), 6)
        Else
            If Not IsEmpty(RWCells("RBookTimeCell")) And RWCells("RBookTimeCell") <> "" Then
                RWCells (UnicodeToCharacter("WBookTimeCell") = RWCells("RBookTimeCell") & "&H5E74") & RWCells(UnicodeToCharacter("RBookTimeCell").Offset(0, 1) & "&H6708")
            End If
            
        End If
    End If
    
    If RWCells("WBookTimeCell").Parent.Name <> "P" Then
        If RWCells("RRoyaltiesCell") < 0.01 And RWCells("RRoyaltiesCell") > 0 Then
            Royalties = RWCells("RRoyaltiesCell")
        ElseIf LastCell < 0.01 And LastCell > 0 Then
            Royalties = LastCell
        Else
            If InStr(RWCells(UnicodeToCharacter("RRoyaltiesCell"), "&H6210&H4EA4")) <> 0 Then
                Royalties = Format(Mid(RWCells(UnicodeToCharacter("RRoyaltiesCell"), InStr(RWCells("RRoyaltiesCell"), "&H6210&H4EA4")) + 2, 5), "0.0000")
            ElseIf InStr(RWCells(UnicodeToCharacter("RRoyaltiesCell"), "&H653E&H6B3E")) <> 0 Then
                Royalties = Format(Mid(RWCells(UnicodeToCharacter("RRoyaltiesCell"), InStr(RWCells("RRoyaltiesCell"), "&H653E&H6B3E")) + 2, 5), "0.0000")
            Else
                Royalties = 0
            End If
        End If
        
        If IsEmpty(RWCells("WRoyaltiesCell")) Then
            RWCells("WRoyaltiesCell") = Format(Royalties, "0.00%")
        End If
    End If
    FillOnce = Royalties
End Function

Function SelectOccupation(ByVal ReadSheet As Worksheet, ByVal WriteSheetCols As Variant, ByVal ColIter As Integer, ByVal RBookTimeCell As Range, ByVal Royalties As Double)
    Dim Occupation As New Collection
    Dim Position As String
    Dim Percentage As Double
    Dim RoomIdCol As Integer
    
    Position = Left(ReadSheet.Range(Left(ReadSheet.Cells(2, ColIter).MergeArea.Address, 4)), 4)
    Select Case ReadSheet.Cells(3, ColIter)
    Case UnicodeToCharacter("&H63D0&H6210&H2460"):
        Select Case Position
        Case UnicodeToCharacter("&H7F6E&H4E1A&H987E&H95EE"):
            Percentage = 0.5
            RoomIdCol = WriteSheetCols("WPropertyConsultantCol")
            
        Case UnicodeToCharacter("&H9500&H552E&H7ECF&H7406"):
            
            Royalties = 0.0006
            Percentage = 0.8
            RoomIdCol = WriteSheetCols("WSalesManagerCol")
            
        Case UnicodeToCharacter("&H73B0&H573A&H7ECF&H7406"):
            If Len(RBookTimeCell) > 6 Or RBookTimeCell < 16 Or RBookTimeCell = 16 And RBookTimeCell.Offset(0, 1) < 6 Then
                Royalties = 0.0005
            Else
                Royalties = 0.0006
            End If
            Percentage = 0.8
            RoomIdCol = WriteSheetCols("WSiteManagerCol")
            
        Case UnicodeToCharacter("&H7B56&H5212&H7ECF&H7406"):
            Royalties = 0.0005
            Percentage = 0.8
            RoomIdCol = WriteSheetCols("WPlanningManagerCol")
            
        Case UnicodeToCharacter("&H7B56&H5212&H5458*"):
            Royalties = 0.0003
            Percentage = 0.8
            RoomIdCol = WriteSheetCols("WPlannerCol")
            
        Case UnicodeToCharacter("&H5BA2&H670D  "):
            Royalties = 0.0001
            Percentage = 0.8
            RoomIdCol = WriteSheetCols("WCustomServiceCol")
        End Select
    Case UnicodeToCharacter("&H63D0&H6210&H2461"):
        Select Case Position
        Case UnicodeToCharacter("&H7F6E&H4E1A&H987E&H95EE"):
            If Len(RBookTimeCell) > 6 Or RBookTimeCell < 16 Or RBookTimeCell = 16 And RBookTimeCell.Offset(0, 1) < 6 Then
                Percentage = 0.3
            Else
                Percentage = 0.45
            End If
            RoomIdCol = WriteSheetCols("WPropertyConsultantCol") + 1
            
        Case UnicodeToCharacter("&H9500&H552E&H7ECF&H7406"):
            Royalties = 0.0006
            Percentage = 0.2
            RoomIdCol = WriteSheetCols("WSalesManagerCol") + 1
          
        Case UnicodeToCharacter("&H73B0&H573A&H7ECF&H7406"):
            If Len(RBookTimeCell) > 6 Or RBookTimeCell < 16 Or RBookTimeCell = 16 And RBookTimeCell.Offset(0, 1) < 6 Then
                Royalties = 0.0005
            Else
                Royalties = 0.0006
            End If
            Percentage = 0.2
            RoomIdCol = WriteSheetCols("WSiteManagerCol") + 1
            
        Case UnicodeToCharacter("&H7B56&H5212&H7ECF&H7406"):
            Royalties = 0.0005
            Percentage = 0.2
            RoomIdCol = WriteSheetCols("WPlanningManagerCol") + 1
           
        Case UnicodeToCharacter("&H7B56&H5212&H5458 "):
            Royalties = 0.0003
            Percentage = 0.2
            RoomIdCol = WriteSheetCols("WPlannerCol") + 1
                
        Case UnicodeToCharacter("&H5BA2&H670D  "):
            Royalties = 0.0001
            Percentage = 0.2
            RoomIdCol = WriteSheetCols("WCustomServiceCol") + 1
        End Select
    Case UnicodeToCharacter("&H63D0&H6210&H2462"):
        If Len(RBookTimeCell) > 6 Or RBookTimeCell < 16 Or RBookTimeCell = 16 And RBookTimeCell.Offset(0, 1) < 6 Then
            Percentage = 0.2
        Else
            Percentage = 0.05
        End If
            RoomIdCol = WriteSheetCols("WPropertyConsultantCol") + 2
    End Select
    
    Occupation.Add Item:=Royalties, Key:="Royalties"
    Occupation.Add Item:=Percentage, Key:="Percentage"
    Occupation.Add Item:=RoomIdCol, Key:="RoomIdCol"
    
    Set SelectOccupation = Occupation
    
End Function

Function MyRound(IntItem As Variant)
    If Not IsNumeric(IntItem) Then Exit Function

    If ((IntItem * 10) Mod 5 = 0) Then
        MyRound = Round(IntItem + 0.0001)
    Else
        MyRound = Round(IntItem)
    End If
End Function

Function UnicodeToCharacter(ByVal Unicode As String)
    Dim WrdArray() As String
    Dim i As Integer
    Dim strg As String
    strg = ""
    WrdArray() = Split(Unicode, "&H")
    For i = LBound(WrdArray) To UBound(WrdArray)
        If WrdArray(i) <> "" Then
            strg = strg & ChrW("&H" & Left(WrdArray(i), 4)) & Right(WrdArray(i), Len(WrdArray(i)) - 4)
        End If
    Next i
    UnicodeToCharacter = strg
End Function


Sub UpdateCells(ByVal RWCells As Collection, ByVal SheetCols As Variant, ByVal AddSheet As Worksheet, ByVal Flag As String, ByVal RowItem As Integer)
    On Error Resume Next
    
    If Split(Flag, "-")(0) = "Read" Then
        
        RWCells.Remove ("RTotalPriceCell")
        RWCells.Add Item:=AddSheet.Cells(RowItem, SheetCols("RTotalPriceCol")), Key:="RTotalPriceCell"
        
        RWCells.Remove ("RBuildingCell")
        RWCells.Add Item:=AddSheet.Cells(RowItem, SheetCols("RBuildingCol")), Key:="RBuildingCell"
        
        RWCells.Remove ("RBookTimeCell")
        Err.Clear
        RWCells.Add Item:=AddSheet.Cells(RowItem, SheetCols("RBookTimeCol")), Key:="RBookTimeCell"
        
        If Err.Number = 5 Then
            RWCells.Add Item:=AddSheet.Cells(RowItem, SheetCols("RRoyaltiesCol")), Key:="RBookTimeCell"
        End If


        RWCells.Remove ("RRoyaltiesCell")
        Err.Clear
        RWCells.Add Item:=AddSheet.Cells(RowItem, SheetCols("RRoyaltiesCol")), Key:="RRoyaltiesCell"
        
        If Err.Number = 5 Then
            RWCells.Add Item:=AddSheet.Cells(RowItem, AddSheet.Rows(3).Find(What:=UnicodeToCharacter("&H63D0&H6210&H70B9&H6570")).Column), Key:="RRoyaltiesCell"
            
        End If

        
    ElseIf Split(Flag, "-")(0) = "Write" Then
        
        RWCells.Remove ("WTotalPriceCell")
        RWCells.Add Item:=AddSheet.Cells(RowItem, SheetCols("WTotalPriceCol")), Key:="WTotalPriceCell"
    
        RWCells.Remove ("WBookTimeCell")
        RWCells.Add Item:=AddSheet.Cells(RowItem, SheetCols("WBookTimeCol")), Key:="WBookTimeCell"
        
        If Split(Flag, "-")(1) <> "Parking" Then
            RWCells.Remove ("WRoyaltiesCell")
            RWCells.Add Item:=AddSheet.Cells(RowItem, SheetCols("WRoyaltiesCol")), Key:="WRoyaltiesCell"
        End If
            
    End If
    
End Sub

Sub CheckError(ByRef ReadCell As Range, ByRef WriteCell As Range, ByVal RTotalPriceCell As Range, ByVal Occupation As Collection, ByVal ReadSheet As Worksheet)
    
    Dim ErrorString As String
    Dim FormulaMultiples As Variant    'Get the Cell Formula Multiple, Like Z7 * I7 * 0.5, FormulaMultiples(0) = Z7
    Dim IfFlag As Boolean
    
    'Set False first, If it is right then remove the Background Color
    WriteCell.Interior.Color = vbYellow
    ReadCell.Interior.Color = vbYellow
    
    If WriteCell.Parent.Name <> "P" Then
        If MyRound(ReadCell) <> MyRound(RTotalPriceCell * Occupation("Royalties") * Occupation("Percentage")) And _
        ReadCell <> RTotalPriceCell * Occupation("Royalties") * Occupation("Percentage") Then
            FormulaMultiples = Split(Mid(ReadCell.Formula, 2, 20), "*")
            ErrorString = " * " & FormulaMultiples(2)
            
            If Len(FormulaMultiples(1)) > 4 Then
                WriteCell.AddComment Text:=UnicodeToCharacter("&H6570&H503C&H4E0D&H5339&H914D")
                WriteCell.Comment.Text Text:=WriteCell.Comment.Text & UnicodeToCharacter("&HFF0C&H8BA1&H7B97&H503C&H662F") & RTotalPriceCell * Occupation("Royalties") * Occupation("Percentage") & _
                " = " & RTotalPriceCell & " * " & Occupation("Royalties") & " * " & Occupation("Percentage")
                WriteCell.Comment.Text Text:=WriteCell.Comment.Text & UnicodeToCharacter("&HFF0C&H5F55&H5165&H503C&H662F") & ReadCell & " = " & ReadSheet.Range(FormulaMultiples(0) & "") & " * " & _
                FormulaMultiples(1) & ErrorString
            Else
                WriteCell.AddComment Text:=UnicodeToCharacter("&H6570&H503C&H4E0D&H5339&H914D")
                WriteCell.Comment.Text Text:=WriteCell.Comment.Text & UnicodeToCharacter("&HFF0C&H8BA1&H7B97&H503C&H662F") & RTotalPriceCell & " * " & Occupation("Royalties") & " * " & _
                Occupation("Percentage") & " = " & RTotalPriceCell * Occupation("Royalties") * Occupation("Percentage")
                WriteCell.Comment.Text Text:=WriteCell.Comment.Text & UnicodeToCharacter("&HFF0C&H5F55&H5165&H503C&H662F") & ReadCell & " = " & ReadSheet.Range(FormulaMultiples(0) & "") & " * " & _
                ReadSheet.Range(FormulaMultiples(1) & "") & ErrorString
            End If
            WriteCell = RTotalPriceCell * Occupation("Royalties") * Occupation("Percentage")
            ReadCell.AddComment Text:=WriteCell.Comment.Text
        ElseIf Not IsEmpty(WriteCell) Then
            WriteCell.AddComment UnicodeToCharacter("&H91CD&H590D&H5F55&H5165")
            WriteCell.Comment.Text Text:=WriteCell.Comment.Text & UnicodeToCharacter("&HFF0C&H5148&H524D&H5F55&H5165&H6E90&H5934&H4E3A ") & WriteCell.Hyperlinks(1).ScreenTip
            WriteCell.Comment.Text Text:=WriteCell.Comment.Text & UnicodeToCharacter("&HFF0C&H73B0&H5728&H5F55&H5165&H6E90&H5934&H4E3A ") & ReadSheet.Parent.Name & "!" & ReadSheet.Name & "!" & _
            ReadCell.Address
            ReadCell.AddComment Text:=WriteCell.Comment.Text
        Else
            WriteCell.Interior.ColorIndex = 0
            ReadCell.Interior.ColorIndex = 0
        End If
    Else
        If Not (ReadCell = 400 And RTotalPriceCell >= 75000 Or ReadCell = 300 And RTotalPriceCell < 75000) And Occupation("RoomIdCol") = 3 Then
            
            WriteCell.AddComment UnicodeToCharacter("&H6570&H503C&H4E0D&H5339&H914D&HFF0C &H603B&H4EF7&H662F") & RTotalPriceCell & UnicodeToCharacter(" &H63D0&H6210&H662F") & ReadCell
            
            ReadCell.AddComment Text:=WriteCell.Comment.Text
        
        ElseIf MyRound(ReadCell) <> MyRound(RTotalPriceCell * Occupation("Royalties")) And _
        ReadCell <> RTotalPriceCell * Occupation("Royalties") And Occupation("RoomIdCol") <> 3 Then
            
            FormulaMultiples = Split(Mid(ReadCell.Formula, 2, 20), "*")
            ErrorString = " * " & FormulaMultiples(2)
                    
            WriteCell.AddComment UnicodeToCharacter("&H6570&H503C&H4E0D&H5339&H914D&HFF0C")
            WriteCell.Comment.Text Text:=WriteCell.Comment.Text & UnicodeToCharacter("&HFF0C&H8BA1&H7B97&H503C&H662F") & RTotalPriceCell * Occupation("Royalties") & " = " & RTotalPriceCell & " * " & Occupation("Royalties")
            WriteCell.Comment.Text Text:=WriteCell.Comment.Text & UnicodeToCharacter("&HFF0C&H5F55&H5165&H503C&H662F") & ReadCell & " = " & ReadSheet.Range(FormulaMultiples(0) & "") & " * " & FormulaMultiples(1) & ErrorString
            
            WriteCell = RTotalPriceCell * Occupation("Royalties")
            ReadCell.AddComment Text:=WriteCell.Comment.Text
        
        ElseIf Not IsEmpty(WriteCell) Then
            WriteCell.AddComment UnicodeToCharacter("&H91CD&H590D&H5F55&H5165")
            WriteCell.Comment.Text Text:=WriteCell.Comment.Text & UnicodeToCharacter("&HFF0C&H5148&H524D&H5F55&H5165&H6E90&H5934&H4E3A ") & WriteCell.Hyperlinks(1).ScreenTip
            WriteCell.Comment.Text Text:=WriteCell.Comment.Text & UnicodeToCharacter("&HFF0C&H73B0&H5728&H5F55&H5165&H6E90&H5934&H4E3A ") & ReadSheet.Parent.Name & "!" & ReadSheet.Name & "!" & _
            ReadCell.Address
            
            WriteCell = RTotalPriceCell * Occupation("Royalties") * Occupation("Percentage")
            ReadCell.AddComment Text:=WriteCell.Comment.Text
        Else
            WriteCell.Interior.ColorIndex = 0
            ReadCell.Interior.ColorIndex = 0
        End If
    End If
End Sub

Sub FillCell(ByRef ReadCell As Range, ByRef WriteCell As Range)

    If IsEmpty(WriteCell) Then
        WriteCell = Format(MyRound(ReadCell), "#.##0")
       
        WriteCell.Parent.Columns.AutoFit
    End If
                                 
    WriteCell.Parent.Hyperlinks.Add Anchor:=WriteCell, _
    Address:=Workbooks(ReadCell.Parent.Parent.Name).FullName, _
    SubAddress:=ReadCell.Parent.Name & "!" & ReadCell.Address, _
    ScreenTip:=ReadCell.Parent.Parent.Name & "!" & ReadCell.Parent.Name & "!" & ReadCell.Address
    
    ReadCell.Parent.Hyperlinks.Add Anchor:=ReadCell, _
    Address:=Workbooks(WriteCell.Parent.Parent.Name).FullName, _
    SubAddress:=WriteCell.Parent.Name & "!" & WriteCell.Address, _
    ScreenTip:=WriteCell.Parent.Name & "!" & WriteCell.Address
    
End Sub

Sub ReadOneSheet()
    Dim ReadWorkbook As Workbook, WriteWorkbook As Workbook
    Dim ReadSheet As Worksheet, ws As Worksheet
    Dim WorkbookName As String, WorksheetName As String, FileName As String
    Dim MyFlag As Boolean
 
    On Error Resume Next
    Dim fd As FileDialog
    Set fd = Application.FileDialog(msoFileDialogOpen)
    fd.Show
    'Var = fd.SelectedItems(1)
    WorkbookName = fd.SelectedItems(1)
    If WorkbookName = "" Then Exit Sub
    
    Set ReadWorkbook = Workbooks(WorkbookName)
    If ReadWorkbook Is Nothing Then Set ReadWorkbook = Workbooks.Open(WorkbookName)
    
    'WorkbookName = ReadWorkbook.Name
    'Workbooks.OpenUnicodeToCharacter("&H9500&H552E&H63D0&H6210&H7ED3&H7B97&H8868(") & WorkbookName & ").xlsx").Open
    
    If Mid(ReadWorkbook.Name, 15, 1) = UnicodeToCharacter("&H6708") Then
        WorksheetName = Mid(ReadWorkbook.Name, 11, 2) & "." & Mid(ReadWorkbook.Name, 14, 1)
    Else
        WorksheetName = Mid(ReadWorkbook.Name, 11, 2) & "." & Mid(ReadWorkbook.Name, 14, 2)
    End If
    
    WorkbookName = UnicodeToCharacter("&H9500&H552E&H63D0&H6210&H7ED3&H7B97&H8868(") & Mid(ReadWorkbook.Name, 9, 4) & ").xlsx"
    Set WriteWorkbook = Workbooks.Open(FileName:=ThisWorkbook.Path & "\" & WorkbookName)
    
    If WriteWorkbook Is Nothing Then
        Workbooks.Add
        ActiveWorkbook.SaveAs FileName:=ThisWorkbook.Path & "\" & WorkbookName
        Set WriteWorkbook = ActiveWorkbook
    End If
    
    MyFlag = True
    For Each ws In Workbooks(WorkbookName).Sheets
        If ws.Name = WorksheetName Then
            Call ClearOneSheet(ws)
            ReadWorkbook.Sheets(1).Cells.Copy ws.Cells
            WriteWorkbook.Save
            ReadWorkbook.Close SaveChanges:=False
            MyFlag = False
            Set ReadSheet = ws
        End If
    Next ws
    
    If MyFlag Then
        ReadWorkbook.Sheets(1).Copy WriteWorkbook.Sheets(1)
        WriteWorkbook.Worksheets(1).Name = WorksheetName
        WriteWorkbook.Save
        ReadWorkbook.Close SaveChanges:=False
        Set ReadSheet = Workbooks(WorkbookName).Sheets(1)
    End If
    
    FileName = Mid(ThisWorkbook.Name, 1, Len(ThisWorkbook.Name) - 5)
    
    ThisWorkbook.SaveCopyAs FileName:=ThisWorkbook.Path & UnicodeToCharacter("\" & FileName & "&H5907&H4EFD.xlsm")
    
    Call ReadNewSheet(ReadSheet)
End Sub

Sub ReadResignationSheets()
    Dim ReadWorkbook As Workbook, WriteWorkbook As Workbook
    Dim ReadSheet As Worksheet, ws As Worksheet
    Dim WorkbookName As String, WorksheetName As String, FileName As String
    Dim MyFlag As Boolean
    Dim MyString As String
    Dim MyStart As Integer
    
    On Error Resume Next
    Dim fd As FileDialog
    Set fd = Application.FileDialog(msoFileDialogOpen)
    fd.Show
    'Var = fd.SelectedItems(1)
    WorkbookName = fd.SelectedItems(1)
    If WorkbookName = "" Then Exit Sub
    
    Set ReadWorkbook = Workbooks(WorkbookName)
    If ReadWorkbook Is Nothing Then Set ReadWorkbook = Workbooks.Open(WorkbookName)
    
    WorkbookName = UnicodeToCharacter("&H79BB&H804C&H4EBA&H5458&H7ED3&H7B97&H8868.xlsx")
    Set WriteWorkbook = Workbooks.Open(FileName:=ThisWorkbook.Path & "\" & WorkbookName)
    
    If WriteWorkbook Is Nothing Then
        Workbooks.Add
        ActiveWorkbook.SaveAs FileName:=WorkbookName
        Set WriteWorkbook = ActiveWorkbook
    End If
    MyString = ReadWorkbook.Sheets(1).Cells(1, 1)
    MyStart = InStr(MyString, "20")
    WorksheetName = Replace(Mid(MyString, MyStart, InStr(MyString, UnicodeToCharacter("&H6708")) - MyStart), "-", ".")
    MyFlag = True
    For Each ws In Workbooks(WorkbookName).Sheets
        If ws.Name = WorksheetName Then
            Call ClearOneSheet(ws)
            ReadWorkbook.Sheets(1).Cells.Copy ws.Cells
            WriteWorkbook.Save
            ReadWorkbook.Close SaveChanges:=False
            MyFlag = False
            Set ReadSheet = ws
        End If
    Next ws
    
    If MyFlag Then
        ReadWorkbook.Sheets(1).Copy WriteWorkbook.Sheets(1)
        WriteWorkbook.Worksheets(1).Name = WorksheetName
        WriteWorkbook.Save
        ReadWorkbook.Close SaveChanges:=False
        Set ReadSheet = Workbooks(WorkbookName).Sheets(1)
    End If
        
    FileName = Mid(ThisWorkbook.Name, 1, Len(ThisWorkbook.Name) - 5)
    
    ThisWorkbook.SaveCopyAs FileName:=ThisWorkbook.Path & UnicodeToCharacter("\" & FileName & "&H5907&H4EFD.xlsm")
    Call ReadResignationSheet(ReadSheet)
End Sub

Sub ReadResignationSheet(ByRef ReadSheet As Worksheet)
    Dim MaxCol As Integer, MinCol As Integer, RowIter As Integer, ColIter As Integer, ReadSheetLastRow As Integer, ReadSheetLastCol As Integer, RoyaltiesCol As Integer
    
    Dim RoomId As String    
    
    Dim ReadSheetCols As Collection, WriteSheetCols As Collection, Occupation As Collection, RWCells As New Collection
    
    Dim WriteSheet As Worksheet
    
    Dim RoomIdRow As Integer, RRoomCol As Integer
   
    Dim ReadCell As Range, WriteCell As Range

    Dim Royalties As Double
    
    On Error Resume Next
    MaxCol = 0
    MaxCol = ReadSheet.Rows(3).Find(What:=UnicodeToCharacter("&H63D0&H6210*"), SearchDirection:=xlPrevious).Column '---------------&H2462")
    MinCol = ReadSheet.Rows(3).Find(What:=UnicodeToCharacter("&H63D0&H6210&H2460")).Column
    
    Set ReadSheetCols = GetReadSheetCols(ReadSheet)
    
    ReadSheetLastCol = ReadSheet.Cells(3, ReadSheet.Columns.Count).End(xlToLeft).Column
    ReadSheetLastRow = ReadSheet.Cells(ReadSheet.Rows.Count, MaxCol).End(xlUp).Row
    RRoomCol = ReadSheet.Rows(3).Find(What:=UnicodeToCharacter("&H623F&H53F7")).Column
    'If MaxCol = 0 Then MaxCol = MinCol + 1
    For RowIter = 4 To ReadSheetLastRow - 1
        On Error Resume Next
        
        Call UpdateCells(RWCells, ReadSheetCols, ReadSheet, "Read-NotParking", RowIter)
        'Debug.Assert RowIter <> 46
        If Not IsEmpty(RWCells("RBuildingCell")) _
                And Left(ReadSheet.Cells(RowIter, ReadSheetCols("RRoomCol")), 1) <> "C" And Left(ReadSheet.Cells(RowIter, ReadSheetCols("RRoomCol")), 1) <> "-" Then '------------------------And Not IsEmpty(ReadSheet(RowIter, ReadSheetLastCol)) Then
            
            Set ReadCell = RWCells("RBuildingCell")
            
            RoomId = GetRoomId(ReadCell)
            
            Set WriteSheet = ThisWorkbook.Sheets(RWCells("RBuildingCell") & "")
            'WriteSh eetLastRow = WriteSheet.Cells(WriteSheet.Rows.Count, 1).End(xlUp).Row
            Set WriteSheetCols = GetWriteSheetCols(WriteSheet)
            
            RoomIdRow = EnterRoomId(RoomId, WriteSheet)
            
            Call UpdateCells(RWCells, WriteSheetCols, WriteSheet, "Write-NotParking", RoomIdRow)
            
            Royalties = FillOnce(RWCells, ReadSheet.Cells(RowIter, ReadSheet.Cells(RowIter, ReadSheet.Columns.Count).End(xlToLeft).Column))
            
            For ColIter = MinCol To MaxCol
                'IfFlag = False
                
                Set ReadCell = ReadSheet.Cells(RowIter, ColIter)
                
                If Not IsEmpty(ReadCell) And IsNumeric(ReadCell) And MyRound(ReadCell) <> 0 Then

                    'If Left(ReadSheet.Cells(3, ColIter), 2) = UnicodeToCharacter("&H63D0&H6210") Then
                        
                    Set Occupation = SelectOccupation(ReadSheet, WriteSheetCols, ColIter, RWCells("RBookTimeCell"), Royalties)
                    
                    Set WriteCell = WriteSheet.Cells(RoomIdRow, Occupation("RoomIdCol"))
                    
                    Call CheckError(ReadCell, WriteCell, RWCells("RTotalPriceCell"), Occupation, ReadSheet)
                    
                    Call FillCell(ReadCell, WriteCell)
                    
                        'IfFlag = True
                    'End If
                End If
            Next ColIter
            
        ElseIf IsEmpty(RWCells("RBuildingCell")) Or _
        Left(ReadSheet.Cells(RowIter, RRoomCol), 1) = "C" Or Left(ReadSheet.Cells(RowIter, RRoomCol), 1) = "-" Then
            'If IsEmpty(ReadSheet.Cells(RowIter, ReadSheetCols("RBuildingCol"))) Then Exit For
            
            Set WriteSheet = ThisWorkbook.Sheets("P")
            
            Set WriteSheetCols = GetWriteSheetCols(WriteSheet)
            RoomId = ReadSheet.Cells(RowIter, ReadSheetCols("RRoomCol"))
            RoomIdRow = EnterRoomId(RoomId, WriteSheet)
            
            Call UpdateCells(RWCells, ReadSheetCols, ReadSheet, "Read-Parking", RowIter)
            
            Call UpdateCells(RWCells, WriteSheetCols, WriteSheet, "Write-Parking", RoomIdRow)
            
            Royalties = FillOnce(RWCells, ReadSheet.Cells(RowIter, ReadSheet.Cells(RowIter, ReadSheet.Columns.Count).End(xlToLeft).Column))
                              
            Set ReadCell = ReadSheet.Cells(RowIter, MinCol)
            
            If Not IsEmpty(ReadCell) And IsNumeric(ReadCell) Then
                    
                'Set False first, If it is right then remove the Background Color
                Set Occupation = SelectOccupation(ReadSheet, WriteSheetCols, MinCol, RWCells("RBookTimeCell"), Royalties)
                
                Set WriteCell = WriteSheet.Cells(RoomIdRow, Occupation("RoomIdCol"))
                
                Call CheckError(ReadCell, WriteCell, RWCells("RTotalPriceCell"), Occupation, ReadSheet)
                        
                Call FillCell(ReadCell, WriteCell)
                      
            End If
        End If
        
            
    Next RowIter
    
End Sub

Sub UpdateHyperLink()
    Dim WriteSheet As Worksheet, ReadSheet As Worksheet
    Dim hl As Hyperlink
    Dim BookAddress As String, RangeAddress As String, SheetAddress As String, Path As String
    Dim WorkbookYear As Integer

    Call OpenAllWorkbook(ThisWorkbook.Path)
    
    For Each WriteSheet In ThisWorkbook.Sheets
        For Each hl In WriteSheet.Hyperlinks
            BookAddress = Split(hl.ScreenTip, "!")(0)
            SheetAddress = Split(hl.ScreenTip, "!")(1)
            RangeAddress = Split(hl.ScreenTip, "!")(2)
            hl.Address = ThisWorkbook.Path & "\" & BookAddress
            hl.SubAddress = SheetAddress & "!" & RangeAddress
            
            On Error Resume Next
            Set ReadSheet = Workbooks(BookAddress & "").Sheets(SheetAddress & "")
            If ReadSheet Is Nothing Then
                Set ReadSheet = Workbooks.Open(FileName:=BookAddress & "").Sheets(SheetAddress & "")
            End If
            
            ReadSheet.Range(RangeAddress & "").Hyperlinks(1).Address = ThisWorkbook.Path & "\" & WriteSheet.Parent.Name
            ReadSheet.Range(RangeAddress & "").Hyperlinks(1).ScreenTip = WriteSheet.Name & "!" & hl.Range.Address
            ReadSheet.Range(RangeAddress & "").Hyperlinks(1).SubAddress = ReadSheet.Range(RangeAddress & "").Hyperlinks(1).ScreenTip
            
            
        Next hl
    Next WriteSheet
    
    If False Then
    For WorkbookYear = 2017 To 2013 Step -1
        On Error Resume Next
        Workbooks(Path & UnicodeToCharacter("\&H9500&H552E&H63D0&H6210&H7ED3&H7B97&H8868(") & WorkbookYear & ").xlsx").Close SaveChanges:=True
    Next WorkbookYear
    
    Workbooks(Path & UnicodeToCharacter("\&H79BB&H804C&H4EBA&H5458&H7ED3&H7B97&H8868.xlsx")).Close SaveChanges:=True
    End If
    
End Sub


Private Sub OpenAllWorkbook(ByVal Path As String)
    Dim WorkbookYear As Integer
    'Dim ReadSheet As Worksheet
    'Dim ReadWorkbook As Workbook
    
    For WorkbookYear = 2017 To 2013 Step -1
        On Error Resume Next
        Workbooks.Open (Path & UnicodeToCharacter("\&H9500&H552E&H63D0&H6210&H7ED3&H7B97&H8868(") & WorkbookYear & ").xlsx")
    Next WorkbookYear
    
    Workbooks.Open (Path & UnicodeToCharacter("\&H79BB&H804C&H4EBA&H5458&H7ED3&H7B97&H8868.xlsx"))
End Sub

Private Sub ClearOneSheet(ByRef ws As Worksheet)
    Dim ReadSheet As Worksheet
    Set ReadSheet = ws
    'Set ReadSheet = Workbooks(UnicodeToCharacter("&H79BB&H804C&H4EBA&H5458&H7ED3&H7B97&H8868.xlsx")).Sheets("2015.9")
    Dim hl As Hyperlink
    Dim RangeAddress As String
    Dim SheetAddress As String
    
    For Each hl In ReadSheet.Hyperlinks
        SheetAddress = Split(hl.ScreenTip, "!")(0)
        RangeAddress = Split(hl.ScreenTip, "!")(1)
        hl.Range.Interior.ColorIndex = 0
        With ThisWorkbook.Sheets(SheetAddress)
            .Range(RangeAddress).ClearContents
            .Range(RangeAddress).ClearComments
            .Range(RangeAddress).ClearHyperlinks
            .Range(RangeAddress).Interior.ColorIndex = 0
            '.Range("$P" & Mid(RangeAddress, 3, 4)).ClearContents
            'If Range("$Q" & Mid(RangeAddress, 3, 4)) > 0.01 Then Range("$Q" & Mid(RangeAddress, 3, 4)).ClearContents
                
        End With
    Next hl
    
    'Call Initial
End Sub

Private Sub ClearWriteSheetAll()
    Dim wkb As Worksheet
    Dim RowIter As Integer
    For Each wkb In ThisWorkbook.Sheets
        RowIter = wkb.Cells(wkb.Rows.Count, 1).End(xlUp).Row
        If RowIter = 1 Then Exit Sub
        If RowIter < 3 Then RowIter = 3
            
        With wkb.Range(wkb.Cells(3, 1), wkb.Cells(RowIter, wkb.Cells(2, wkb.Columns.Count).End(xlToLeft).Column))
            .ClearContents
            .ClearComments
            .ClearHyperlinks
            .Interior.ColorIndex = 0
            
        End With
        
    Next wkb
    'Call Initial()
End Sub

Private Sub ClearReadSheetAll()
    Dim wkb As Worksheet
    Dim RowIter As Integer
    Dim hl As Hyperlink
    
    For Each wkb In Workbooks(UnicodeToCharacter("&H9500&H552E&H63D0&H6210&H7ED3&H7B97&H8868(2013).xlsx")).Sheets
    
        For Each hl In wkb.Hyperlinks
        
        With hl.Range
            .ClearHyperlinks
            .Font.Color = vbBlack
            .Font.Underline = False
            .Interior.ColorIndex = 0
        End With
        
        Next hl
    Next wkb
    
    'Call Initial()
End Sub

Private Sub CopyOneSheet()
    Dim WorkbookMonth As Integer
    Dim WorkbookName As String
    
    Dim WriteWorkbook As Workbook
    Dim ReadSheet As Worksheet
    
    Dim WorkbookYear As String
    WorkbookYear = "2016"
    
    Dim Path As String
    Path = UnicodeToCharacter("G:\Sales\" '& Right(WorkbookYear, 2) & "&H5E74&H63D0&H6210\")
    
    Workbooks.Add
    ActiveWorkbook.SaveAs FileName:=UnicodeToCharacter("G:\Sales\" & WorkbookYear & "&H63D0&H70B9&H7ED3&H7B97&H60C5&H51B5&H8868.xlsx")
    
    If Left(ActiveWorkbook.Name, 4) = UnicodeToCharacter("&H9500&H552E&H63D0&H6210") Then
        Set WriteWorkbook = Workbooks(UnicodeToCharacter("&H9500&H552E&H63D0&H6210&H7ED3&H7B97&H8868(") & WorkbookYear & ").xlsx")
        For WorkbookMonth = 1 To 12
            WorkbookName = UnicodeToCharacter("&H9500&H552E&H63D0&H6210&H7ED3&H7B97&H8868(") & WorkbookYear & UnicodeToCharacter("-" & WorkbookMonth & "&H6708&HFF09.xls")
            On Error Resume Next
            Workbooks.Open (Path & WorkbookName)
            If Err.Number = 0 Then
                Set ReadSheet = Workbooks(WorkbookName).ActiveSheet
                ReadSheet.Copy WriteWorkbook.Worksheets(1)
                WriteWorkbook.Worksheets(1).Name = Right(WorkbookYear, 2) & "." & WorkbookMonth
                Workbooks(WorkbookName).Close
            End If
        Next WorkbookMonth
        
    Else
        Set WriteWorkbook = Workbooks(WorkbookYear & UnicodeToCharacter("&H63D0&H70B9&H7ED3&H7B97&H60C5&H51B5&H8868.xlsx"))
        For WorkbookMonth = 1 To 12
            WorkbookName = WorkbookYear & UnicodeToCharacter("-" & WorkbookMonth & "&H6708&H63D0&H70B9&H7ED3&H7B97&H60C5&H51B5.xls")
            On Error Resume Next
            Workbooks.Open (Path & WorkbookName)
            If Err.Number = 0 Then
                Set ReadSheet = Workbooks(WorkbookName).Sheets(1)
                ReadSheet.Copy WriteWorkbook.Worksheets(1)
                WriteWorkbook.Worksheets(1).Name = Right(WorkbookYear, 2) & "." & WorkbookMonth
                Workbooks(WorkbookName).Close
            End If
        Next WorkbookMonth
    End If
    
    Workbooks(WriteWorkbook.Name).Close SaveChanges:=True
End Sub

Private Sub CopySheet()

    Dim ReadSheet As Worksheet
    For Each ReadSheet In Workbooks(UnicodeToCharacter("&H9500&H552E&H63D0&H6210&H7ED3&H7B97&H8868(2012).xlsx")).Sheets
        If Len(ReadSheet.Name) = 8 Then
            Call Read2012Sheet(ReadSheet)
        End If
    Next ReadSheet
        
End Sub

Private Sub Read2012Sheet(ByRef ReadSheet As Worksheet)
    Dim MaxCol As Integer, MinCol As Integer, RowIter As Integer, ColIter As Integer, ReadSheetLastRow As Integer, ReadSheetLastCol As Integer
    
    Dim RoomId As String
    
    Dim ReadSheetCols As Collection, WriteSheetCols As Collection, Occupation As Collection, RWCells As New Collection
    
    Dim WriteSheet As Worksheet
    
    Dim RoomIdRow As Integer, TypeCol As Integer
    Dim Royalties As Double
   
    Dim ReadCell As Range, WriteCell As Range

    Set ReadSheetCols = GetReadSheetCols(ReadSheet)
    
    MinCol = ReadSheet.Cells.Rows(3).Find(What:=UnicodeToCharacter("&H63D0&H6210*")).Column
    MaxCol = ReadSheet.Cells.Rows(3).Find(What:=UnicodeToCharacter("&H63D0&H6210&H2460"), SearchDirection:=xlPrevious).Column
    ReadSheetLastRow = ReadSheet.Cells(ReadSheet.Rows.Count, MaxCol).End(xlUp).Row
    ReadSheetLastCol = ReadSheet.Cells(4, ReadSheet.Columns.Count).End(xlToLeft).Column
    TypeCol = ReadSheet.Cells.Rows(3).Find(What:=UnicodeToCharacter("&H7C7B&H522B")).Column
    
    On Error Resume Next
    For RowIter = 4 To ReadSheetLastRow 'RowIter = 4 Start Row
        
        If Not IsEmpty(ReadSheet.Cells(RowIter, ReadSheetCols("RRoomCol"))) Then
            
            Call UpdateCells(RWCells, ReadSheetCols, ReadSheet, "Read-NotParking", RowIter)
            
            Set ReadCell = ReadSheet.Cells(RowIter, ReadSheetCols("RBuildingCol"))
            
            RWCells.Remove ("RBookTimeCell")
            RWCells.Add Item:="", Key:="RBookTimeCell"
        
            RWCells.Remove ("RRoyaltiesCell")
            RWCells.Add Item:=0.0015, Key:="RRoyaltiesCell"
        
            RoomId = GetRoomId(ReadCell)
            
            Set WriteSheet = ThisWorkbook.Sheets(ReadCell & "")
            
            Set WriteSheetCols = GetWriteSheetCols(WriteSheet)
            
            RoomIdRow = EnterRoomId(RoomId, WriteSheet)
            
            Call UpdateCells(RWCells, WriteSheetCols, WriteSheet, "Write-NotParking", RoomIdRow)
             
            Royalties = FillOnce(RWCells, ReadSheet.Cells(RowIter, ReadSheet.Cells(RowIter, ReadSheet.Columns.Count).End(xlToLeft).Column))
            
            RWCells.Remove ("RBookTimeCell")
            RWCells.Add Item:=ReadSheet.Cells(1, 1), Key:="RBookTimeCell"
        
            For ColIter = MinCol To MaxCol

                Set ReadCell = ReadSheet.Cells(RowIter, ColIter)
                
                If Not IsEmpty(ReadCell) And IsNumeric(ReadCell) And MyRound(ReadCell) <> 0 Then

                    If Left(ReadSheet.Cells(3, ColIter), 2) = UnicodeToCharacter("&H63D0&H6210") Then
                        
                        Set Occupation = SelectOccupation(ReadSheet, WriteSheetCols, ColIter, RWCells("RBookTimeCell"), Royalties)
                        
                        If ReadSheet.Cells(RowIter, TypeCol) = "B" Then
                        
                            Occupation.Remove ("Royalties")
                            Occupation.Add Item:=0.00075, Key:="Royalties"
                            Occupation.Remove ("Percentage")
                            Occupation.Add Item:=0.6, Key:="Percentage"
                            Occupation.Remove ("RoomIdCol")
                            Occupation.Add Item:=WriteSheetCols("WPropertyConsultantCol"), Key:="RoomIdCol"
                        End If
                        
                        Set WriteCell = WriteSheet.Cells(RoomIdRow, Occupation("RoomIdCol"))
                        
                        Call CheckError(ReadCell, WriteCell, RWCells("RTotalPriceCell"), Occupation, ReadSheet)
                        
                        Call FillCell(ReadCell, WriteCell)
                        
                    End If
                End If
            Next ColIter
        End If
    Next RowIter
    
End Sub





