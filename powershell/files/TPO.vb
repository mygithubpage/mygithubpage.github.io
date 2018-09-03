Option Explicit

Function CreateSaveDoc(ByVal FileContent As String, ByRef openPath As String, ByVal TPOIter As String)
    Dim savePath As String
    Dim CpDoc As Document, SaveDoc As Document

    If Len(TPOIter) = 1 Then TPOIter = "0" & TPOIter
    openPath = Environ("HOMEDRIVE") & Environ("HOMEPATH") & "\Downloads\TOEFL\TPO" & FileContent
    savePath = Environ("HOMEDRIVE") & Environ("HOMEPATH") & "\Downloads\TOEFL\TPO\TPO" & TPOIter

    Documents.Add
    Documents.Item(1).SaveAs2 FileName:=savePath & "\TPO" & TPOIter & FileContent & ".docx"
    Set SaveDoc = Documents(savePath & "\TPO" & TPOIter & FileContent & ".docx")
    Set CreateSaveDoc = SaveDoc
End Function

Sub TPOReading(ByVal TPOIter As String)
    Dim openPath As String, fName As String
    Dim CpDoc As Document, editDoc As Document
    Dim PassageIter As Integer
    
    Set editDoc = CreateSaveDoc(FileContent:=" Reading", openPath:=openPath, TPOIter:=TPOIter)
    fName = Dir(openPath & "\TPO " & TPOIter & " Reading\")
    PassageIter = 1
    
    While (fName <> "")
        Set CpDoc = Documents.Open(FileName:=openPath & "\TPO " & TPOIter & " Reading\" & fName)
        
        MakeReadingFile CpDoc
        
        AddHeading "Passage" & PassageIter, editDoc, editDoc.content.End

        CpDoc.Range(Start:=CpDoc.content.Start, End:=CpDoc.content.End).Copy
        editDoc.Range(Start:=editDoc.content.End - 1, End:=editDoc.content.End - 1).Paste
        editDoc.content.InsertParagraphAfter
        CpDoc.Close SaveChanges:=False
        fName = Dir
        PassageIter = PassageIter + 1
    Wend
    SetFileFormat editDoc
    editDoc.Close SaveChanges:=True
End Sub

Sub MakeReadingFile(ByRef CpDoc As Document)
    Dim myAnswerFind As Find, myQuestionFind As Find, myStartFind As Find, myEndFind As Find, myFind As Find
    Dim myAnswer As String, mySquare As String, mySelection As String, myChoices As String, Category As String
    Dim myQuestion As Integer, myAnswerIter As Integer, myQuestionIter As Integer, Iter As Integer
    Dim myRange As Range
    Dim myAnswers As Variant
    
    Set myAnswerFind = CpDoc.content.Find
    myAnswerFind.Execute FindText:="²Î¿¼´ð°¸", ReplaceWith:="Reference Answer"
    SetFileFormat CpDoc
    CpDoc.Save
    
    Set myQuestionFind = CpDoc.content.Find
    
    Set myEndFind = CpDoc.content.Paragraphs(2).Range.Find
    
    Set myAnswerFind = CpDoc.content.Find
    myAnswerFind.Execute FindText:="Reference Answer", ReplaceWith:="Reference Answer"
    Set myRange = myAnswerFind.Parent.Paragraphs(1).Next(1).Range
    myQuestion = 0
    'Find Answer Position
    While myRange.End < CpDoc.content.End And Len(myRange) > 2
        
        myQuestion = myQuestion + 1
        myAnswer = GetAnswerText(myRange.Text)
        
        'Debug.Assert myQuestion <> 1
        'Get Question Find Range
        Set myStartFind = FindQuestion(CpDoc, myEndFind.Parent.Paragraphs(1).Range.Start, myAnswerFind.Parent.Paragraphs(1).Range.Start, myQuestion)
        
        Set myEndFind = FindQuestion(CpDoc, myStartFind.Parent.Paragraphs(1).Range.Start, myAnswerFind.Parent.Paragraphs(1).Range.Start, myQuestion + 1)
       
        If Len(myAnswer) > 10 Then
            'Last question with text in multiple line
           
            Set myQuestionFind = FindQuestion(CpDoc, myQuestionFind.Parent.Start, myAnswerFind.Parent.Start, myQuestion)
            If InStr(myQuestionFind.Parent.Paragraphs(1).Range.Sentences.Last, "3") <> 0 Then
                Set myQuestionFind = CpDoc.Range(myQuestionFind.Parent.End, myAnswerFind.Parent.Start).Find
                
                For myAnswerIter = 1 To 2
                    myAnswer = Left(myRange.Text, Len(myRange.Text) - 2)
                    Category = Split(myAnswer, ":")(0)
                    
                    If myAnswerIter = 1 Then Category = Right(Category, Len(Category) - 3)
                    
                    myQuestionFind.Execute FindText:=RemovePreceedingWhiteSpace(Right(Category, Len(Category) - 1)), MatchCase:=True
                    myAnswers = Split(Split(myAnswer, ":")(1), ";")
                    
                    For Iter = 0 To UBound(myAnswers)
                        myQuestionFind.Parent.Paragraphs(1).Next(Iter + 1).Range.Characters.First.InsertAfter (myAnswers(Iter))
                    Next Iter
                    
                    If myRange.End >= CpDoc.content.End Then Exit For
                    Set myRange = myRange.Paragraphs(1).Next(1).Range
                    'Exit For
                    Set myQuestionFind = CpDoc.Range(myQuestionFind.Parent.End, myAnswerFind.Parent.Start).Find
                Next myAnswerIter
                
            Else
                Set myQuestionFind = CpDoc.Range(myQuestionFind.Parent.End, myAnswerFind.Parent.Start).Find
            
                For myAnswerIter = 1 To 3
                    myAnswer = Left(myRange.Text, Len(myRange.Text) - 2)
                    
                    
                    If InStr(myAnswer, ".") <> 0 Then myAnswer = Left(myAnswer, Len(myAnswer) - 3)
                    myQuestionFind.Execute FindText:=Split(myAnswer, "...")(0)
                    myQuestionFind.Parent.Paragraphs(1).Range.Bold = True
                    
                    If myRange.End >= CpDoc.content.End Then Exit For
                    Set myRange = myRange.Paragraphs(1).Next(1).Range
                    
                    'Set myQuestionFind = CpDoc.Range(myQuestionFind.Parent.End, myAnswerFind.Parent.Start).Find
                Next myAnswerIter
            End If
            
        'Question with multiple answer chioce in one line, like 13. 1, 3, 5
        ElseIf Len(myAnswer) > 3 And Len(myAnswer) < 10 Then
            For myQuestionIter = 0 To (Len(myAnswer) - 1) / 2 - 1
                Set myFind = CpDoc.Range(myQuestionFind.Parent.Start, myAnswerFind.Parent.Start).Find
                myFind.Execute FindText:="¡ð"
                
                For myAnswerIter = 2 To Split(myAnswer, ", ")(myQuestionIter)
                    'Exit For
                    Set myFind = CpDoc.Range(Start:=myFind.Parent.Paragraphs(1).Range.End, End:=myAnswerFind.Parent.Start).Find
                    myFind.Execute FindText:="¡ð"
                Next myAnswerIter
                'Exit For
                myFind.Parent.Paragraphs(1).Range.Bold = True
            Next myQuestionIter
        Else
        
            'Multiple Choice Selection
            Set myFind = CpDoc.Range(myStartFind.Parent.End, myEndFind.Parent.Start).Find
            myFind.Execute FindText:="¡ð"
                
            For myAnswerIter = 2 To myAnswer
                'Exit For
                Set myFind = CpDoc.Range(Start:=myFind.Parent.Paragraphs(1).Range.End, End:=myEndFind.Parent.Start).Find
                myFind.Execute FindText:="¡ð"
            Next myAnswerIter
    
            myFind.Parent.Paragraphs(1).Range.Bold = True
        End If
        
        If myRange.End < CpDoc.content.End Then Set myRange = myRange.Paragraphs(1).Next(1).Range
        
         'Insert Text
        If myEndFind.Parent.Paragraphs(1).Range.Find.Execute(FindText:="¡ö") Then mySquare = "¡ö"
        If myEndFind.Parent.Paragraphs(1).Range.Find.Execute(FindText:="¨€") Then mySquare = "¨€"
        
        
        If myEndFind.Parent.Paragraphs(1).Range.Find.Execute(FindText:=mySquare) Then
            
            Set myFind = CpDoc.Range(myStartFind.Parent.End, myEndFind.Parent.Start).Find
            myFind.Execute FindText:=mySquare
            
            'myQuestion = Split(myRange.Paragraphs(1).Next(1).Range.Text, ".")(0)
            myAnswer = GetAnswerText(myRange.Text)
            
            For myAnswerIter = 2 To myAnswer
                myFind.Parent.InsertAfter (" ")
                Set myFind = CpDoc.Range(Start:=myFind.Parent.End, End:=myEndFind.Parent.Start).Find
                myFind.Execute FindText:=mySquare
            Next myAnswerIter
            myFind.Parent.Text = "[" & myEndFind.Parent.Paragraphs(1).Next(1).Range.Sentences(1) & "]"
            myFind.Parent.Sentences(1).Characters.Last.Delete
            CpDoc.Range(myFind.Parent.Sentences(1).Start, myFind.Parent.Sentences(1).End).Bold = True
            
            myQuestion = myQuestion + 1
            Set myRange = myRange.Paragraphs(1).Next(1).Range
            
        End If
        
    Wend
    
    'Delete reference answer
    
    If False And myAnswerFind.Found Then
        myAnswerIter = 1
        While myAnswerFind.Parent.Paragraphs(1).Previous(myAnswerIter).Range.Words.Count <= 3
            myAnswerIter = myAnswerIter + 1
        Wend
        CpDoc.Range(myAnswerFind.Parent.Paragraphs(1).Previous(myAnswerIter - 1).Range.Start, CpDoc.content.End).Delete
    End If
    
End Sub

Sub TPOListening(ByVal TPOIter As String)
    Dim openPath As String
    Dim CpDoc As Document, editDoc As Document
    
    Set editDoc = CreateSaveDoc(FileContent:=" Listening", openPath:=openPath, TPOIter:=TPOIter)
    Set CpDoc = Documents.Open(FileName:=openPath & "\TPO" & TPOIter & ".txt")
    
    CpDoc.Range(Start:=CpDoc.content.Start, End:=CpDoc.content.End).Copy
    editDoc.Range(Start:=editDoc.content.End - 1, End:=editDoc.content.End - 1).Paste
    
    CpDoc.Close
    
    MakeListeningFile editDoc
    SetFileFormat editDoc
    editDoc.Close SaveChanges:=True
End Sub

Sub MakeListeningFile(editDoc As Document)
    Dim AnswerFind As Find, QuestionFind As Find, myFind As Find, myStartFind As Find, myEndFind As Find
    Dim mySelectionIter As Integer, QuestionIter As Integer, AnswerIter As Integer, PassageIter As Integer
    Dim CpDoc As Document
    Dim ActiveTable As Table
    Dim mySelection As String, mySelections As String
    Dim myFlag As Boolean
    
    Set editDoc = ActiveDocument
    editDoc.content.Find.Execute FindText:="#", ReplaceWith:="", Replace:=wdReplaceAll
    editDoc.content.Find.Execute FindText:="¡£", ReplaceWith:=". ", Replace:=wdReplaceAll
    
    'Add Delimiter ========
    If Len(editDoc.content.Paragraphs(1).Range.Text) <> 8 Then
        editDoc.content.InsertParagraphBefore
        editDoc.content.InsertBefore Text:="======"
    End If
    
    If Len(editDoc.content.Paragraphs.Last.Range.Text) <> 8 Then
        editDoc.content.InsertParagraphAfter
        editDoc.content.InsertAfter Text:="======"
    End If
    
    Set myFind = editDoc.content.Find
    If myFind.Execute("18.") And myFind.Parent.Paragraphs(1).Range.Characters(1) = "1" Then myFlag = True
    
    Set AnswerFind = editDoc.content.Find
    AnswerFind.Execute FindText:="ÕýÈ·´ð°¸"
    QuestionIter = 0
    
    Set myEndFind = editDoc.content.Paragraphs(1).Range.Find
    PassageIter = 1
    While AnswerFind.Found = True
    
        'Revert Script Ans Questions
        If Len(AnswerFind.Parent.Paragraphs(1).Previous(1).Range.Text) = 8 Then
            Set myStartFind = editDoc.Range(myEndFind.Parent.Paragraphs(1).Range.Start, editDoc.content.End).Find
            myStartFind.Execute FindText:="======*", MatchWildcards:=True
            
            Set myEndFind = editDoc.Range(myStartFind.Parent.Paragraphs(1).Range.End, editDoc.content.End).Find
            myEndFind.Execute FindText:="======*", MatchWildcards:=True
            
            editDoc.Range(myStartFind.Parent.Start, myEndFind.Parent.Start).Cut
            editDoc.Range(AnswerFind.Parent.Paragraphs(1).Previous(1).Range.Start, AnswerFind.Parent.Paragraphs(1).Previous(1).Range.Start).Paste
            editDoc.Range(myStartFind.Parent.Start, myEndFind.Parent.Start).InsertParagraphBefore
            
            editDoc.Range(myStartFind.Parent.Start, myEndFind.Parent.Start).Text = "Passage " & PassageIter
            editDoc.Range(myStartFind.Parent.Start, myEndFind.Parent.Start).Paragraphs(1).Range.Bold = True
            PassageIter = PassageIter + 1
            
            Set myStartFind = editDoc.Range(AnswerFind.Parent.Paragraphs(1).Previous(1).Range.Start, editDoc.content.End).Find
        End If
        
        QuestionIter = QuestionIter + 1
        If Not myFlag And QuestionIter > 17 Then QuestionIter = QuestionIter Mod 17
        'Debug.Assert QuestionIter <> 14
        
        Set QuestionFind = FindQuestion(editDoc, myEndFind.Parent.End, AnswerFind.Parent.Start, QuestionIter)
        
        QuestionFind.Parent.Paragraphs(1).Next(4).Range.InsertParagraphAfter

        mySelections = Mid(String:=AnswerFind.Parent.Paragraphs(1).Range.Sentences(1), Start:=6, Length:=20)
        mySelections = Left(String:=mySelections, Length:=Len(mySelections) - 2)

        On Error Resume Next
        mySelectionIter = 0
        mySelection = Split(Expression:=mySelections, Delimiter:=" ")(mySelectionIter)
         
        'Yes or No Table
        If Len(mySelections) > 5 Then
            If mySelection = "Y" Or mySelection = "N" Then
                'Create Table
                Set ActiveTable = editDoc.Tables.Add(Range:=editDoc.Range(Start:=QuestionFind.Parent.Paragraphs(1).Next(4).Range.End, End:=QuestionFind.Parent.Paragraphs(1).Next(4).Range.End), NumRows:=(Len(mySelections) + 1) / 2 + 1, NumColumns:=3)
                ActiveTable.Borders.OutsideLineStyle = wdLineStyleSingle
                ActiveTable.Borders.InsideLineStyle = wdLineStyleSingle
                ActiveTable.Cell(Row:=1, Column:=2).Range = "Yes"
                ActiveTable.Cell(Row:=1, Column:=3).Range = "No"
            End If

            Do
                'Fill Table
                Select Case mySelection
                Case "Y": AnswerIter = 2
                Case "N": AnswerIter = 3
                End Select
                ActiveTable.Cell(Row:=mySelectionIter + 2, Column:=1).Range = QuestionFind.Parent.Paragraphs(1).Next(mySelectionIter + 1).Range
                ActiveTable.Cell(Row:=mySelectionIter + 2, Column:=AnswerIter).Range = mySelection
                mySelectionIter = mySelectionIter + 1
                Err.Clear
                mySelection = Split(Expression:=mySelections, Delimiter:=" ")(mySelectionIter)
            Loop Until Err.Number <> 0
            editDoc.Range(Start:=QuestionFind.Parent.Paragraphs(1).Range.End, End:=QuestionFind.Parent.Paragraphs(1).Next(4).Range.End).Delete
        Else
            Do
                Select Case mySelection
                Case "A": AnswerIter = 1
                Case "B": AnswerIter = 2
                Case "C": AnswerIter = 3
                Case "D": AnswerIter = 4
                End Select
                
                QuestionFind.Parent.Paragraphs(1).Next(AnswerIter).Range.Bold = True
                mySelectionIter = mySelectionIter + 1
                Err.Clear
                mySelection = Split(Expression:=mySelections, Delimiter:=" ")(mySelectionIter)
            Loop Until Err.Number <> 0
            
            
        End If
        
        'Delete Chinese text
        If Len(AnswerFind.Parent.Paragraphs(1).Next(1).Range.Text) = 8 Then
            myStartFind.Execute FindText:="======*", MatchWildcards:=True
            
            Set myEndFind = editDoc.Range(AnswerFind.Parent.Paragraphs(1).Next(1).Range.End, editDoc.content.End).Find
            myEndFind.Execute FindText:="======*", MatchWildcards:=True
            
            editDoc.Range(myStartFind.Parent.Start, myEndFind.Parent.Start).Delete
        End If
    
        Set AnswerFind = editDoc.Range(AnswerFind.Parent.Paragraphs(1).Next(1).Range.Start, editDoc.content.End).Find
        AnswerFind.Execute FindText:="ÕýÈ·´ð°¸"
    Wend
    
    editDoc.content.Find.Execute FindText:="=", ReplaceWith:="", Replace:=wdReplaceAll
    
    AddSpace editDoc, ","
    AddSpace editDoc, "."
    
End Sub

Sub TPOSpeaking(ByVal TPOIter As String)
    Dim CpDocS As Document, CpDocSS As Document, editDoc As Document
    Dim openPath As String

    Set editDoc = CreateSaveDoc(FileContent:=" Speaking", openPath:=openPath, TPOIter:=TPOIter)
    
    Set CpDocS = Documents.Open(FileName:=openPath & "\TPO1-33 Speaking\TPO 1-30 Speaking.docx")
    Set CpDocSS = Documents.Open(FileName:=openPath & "\TPO1-33 Speaking Sample\TOEFL TPO1-24.docx")
    
    MakeSpeakingFile editDoc, CpDocS, CpDocSS, TPOIter
    
    SetFileFormat editDoc
    
    CpDocS.Close SaveChanges:=False
    CpDocSS.Close SaveChanges:=False
    editDoc.Close SaveChanges:=True
End Sub

Sub MakeSpeakingFile(ByRef editDoc As Document, ByRef CpDocS As Document, ByRef CpDocSS As Document, ByVal TPOIter As Integer)
    
    Dim SFindStart As Find, SFindEnd As Find, mySFind As Find
    Dim SSFindStart As Find, SSFindEnd As Find, mySSFind As Find
    Dim QuestionIter As Integer
    
    CpDocS.Activate
    Set SFindStart = ActiveDocument.content.Find
    Set SFindEnd = ActiveDocument.content.Find
    SFindStart.Execute FindText:="TPO" & TPOIter
    SFindEnd.Execute FindText:="TPO" & TPOIter + 1
        
        
    'Exit Sub
    CpDocS.Range(Start:=SFindStart.Parent.Paragraphs(1).Range.End, End:=SFindEnd.Parent.Paragraphs(1).Range.Start).Copy
    editDoc.Range(editDoc.content.End - 1, editDoc.content.End).Paste
     
    CpDocSS.Activate
    Set SSFindStart = ActiveDocument.content.Find
    Set SSFindEnd = ActiveDocument.content.Find
    If Not SSFindStart.Execute(FindText:="TPO" & TPOIter) Then SSFindStart.Execute FindText:="TPO " & TPOIter
    If Not SSFindEnd.Execute(FindText:="TPO" & TPOIter + 1) Then SSFindEnd.Execute FindText:="TPO " & TPOIter + 1
    
    For QuestionIter = 1 To 6
        CpDocSS.Activate
        Set mySSFind = ActiveDocument.Range(Start:=SSFindStart.Parent.Paragraphs(1).Range.End, End:=SSFindEnd.Parent.Paragraphs(1).Range.Start).Find
        editDoc.Activate
        Set mySFind = ActiveDocument.content.Find
    
        mySSFind.Execute FindText:=QuestionIter & "."
        mySSFind.Parent.Paragraphs(1).Next(1).Range.Copy
        
        If QuestionIter <> 6 Then
            mySFind.Execute FindText:="#" & QuestionIter + 1
            
            AddHeading "#" & QuestionIter & " Sample Response", editDoc, mySFind.Parent.Start - 1
        
            editDoc.Range(mySFind.Parent.Start, mySFind.Parent.Start + 1).Paste
        Else
            While Len(editDoc.Paragraphs(editDoc.Paragraphs.Count).Range) < 10
                editDoc.Paragraphs(editDoc.Paragraphs.Count).Range.Delete
            Wend
            
            AddHeading "#6" & " Sample Response", editDoc, editDoc.content.End
            
            editDoc.Range(editDoc.content.End - 1, editDoc.content.End).Paste
        End If
    Next QuestionIter

End Sub

Sub TPOWriting(ByVal TPOIter As String)
    Dim CpDocDW As Document, CpDocTW As Document, CpDocTWS As Document, editDoc As Document
    Dim openPath As String

    Set editDoc = CreateSaveDoc(FileContent:=" Writing", openPath:=openPath, TPOIter:=TPOIter)
    
    Set CpDocDW = Documents.Open(FileName:=openPath & "\TPO1-33 Writing\TPO 1-33 DW.docx")
    Set CpDocTW = Documents.Open(FileName:=openPath & "\TPO1-33 Writing\TPO1-30 Writing.docx")
    Set CpDocTWS = Documents.Open(FileName:=openPath & "\TPO1-33 Writing Sample\TPO1-26 Writing Sample.doc")
    
    MakeWritingFile editDoc, CpDocDW, CpDocTW, CpDocTWS, TPOIter
    
    SetFileFormat editDoc
    
    CpDocDW.Close SaveChanges:=False
    CpDocTW.Close SaveChanges:=False
    CpDocTWS.Close SaveChanges:=False
    editDoc.Close SaveChanges:=True
End Sub

Sub MakeWritingFile(ByRef editDoc As Document, ByRef CpDocDW As Document, ByRef CpDocTW As Document, ByRef CpDocTWS As Document, ByVal TPOIter As Integer)
    
    Dim FindStart As Find, FindEnd As Find, myFind As Find
    
    CpDocTW.Activate
    Set FindStart = ActiveDocument.content.Find
    Set FindEnd = ActiveDocument.content.Find
    FindStart.Execute FindText:="TPO" & TPOIter
    FindEnd.Execute FindText:="TPO" & TPOIter + 1
    
    CpDocTW.Range(Start:=FindStart.Parent.Paragraphs(1).Range.End, End:=FindEnd.Parent.Paragraphs(1).Range.Start).Copy
    editDoc.Range(editDoc.content.End - 1, editDoc.content.End).Paste
    
    CpDocTWS.Activate
    Set FindStart = ActiveDocument.content.Find
    Set FindEnd = ActiveDocument.content.Find
    If TPOIter < 9 Then
        FindStart.Execute FindText:="TPO 0" & TPOIter
        FindEnd.Execute FindText:="TPO 0" & TPOIter + 1
    ElseIf TPOIter = 9 Then
        FindStart.Execute FindText:="TPO 0" & TPOIter
        FindEnd.Execute FindText:="TPO " & TPOIter + 1
    Else
        FindStart.Execute FindText:="TPO " & TPOIter
        FindEnd.Execute FindText:="TPO " & TPOIter + 1
    End If
    
    Set myFind = CpDocTWS.Range(Start:=FindStart.Parent.Paragraphs(1).Range.End, End:=FindEnd.Parent.Paragraphs(1).Range.Start).Find
    myFind.Execute FindText:="ÀýÎÄ£¨½ö¹©²Î¿¼£©"
    
    CpDocTWS.Range(Start:=myFind.Parent.Paragraphs(1).Range.End, End:=FindEnd.Parent.Paragraphs(1).Range.Start).Copy
    
    AddHeading "Sample Response", editDoc, editDoc.content.End
    
    editDoc.Range(editDoc.content.End - 1, editDoc.content.End).Paste
    
    CpDocDW.Activate
    Set FindStart = ActiveDocument.content.Find
    Set FindEnd = ActiveDocument.content.Find
    
    FindStart.Execute FindText:="TPO" & TPOIter
    FindEnd.Execute FindText:="TPO" & TPOIter + 1
    
    editDoc.Range(editDoc.content.End - 1, editDoc.content.End).InsertParagraphBefore
    CpDocDW.Range(Start:=FindStart.Parent.Paragraphs(1).Range.End, End:=FindEnd.Parent.Paragraphs(1).Range.Start).Copy
    editDoc.Range(editDoc.content.End - 1, editDoc.content.End).Paste
    
    Set myFind = editDoc.content.Find
    myFind.Execute FindText:="¶ÀÁ¢Ð´×÷·¶ÎÄ"
    myFind.Parent.Paragraphs(1).Range.InsertParagraphBefore
    myFind.Parent.Paragraphs(1).Range.Delete
    
    Set myFind = editDoc.content.Find
    myFind.Execute FindText:="Ä£°å"
    myFind.Parent.Paragraphs(1).Range.Delete
    
    Set myFind = editDoc.content.Find
    myFind.Execute FindText:="Use specific reasons and examples to support your answer."
    
    AddHeading "Sample Response", editDoc, myFind.Parent.Paragraphs(1).Range.End
End Sub

'-------------------------------------------------------------------------------------------------------------------------------------------------------------
'Making TPO Files
'-------------------------------------------------------------------------------------------------------------------------------------------------------------
Sub MakeTPO()
    Dim TPOIter As String, savePath As String, Iter As Integer
    
    For Iter = 16 To 16
        TPOIter = "" & Iter
        savePath = Environ("HOMEDRIVE") & Environ("HOMEPATH") & "\Downloads\TOEFL\TPO\TPO" & TPOIter
        
        If (Dir(savePath, vbDirectory) = "") Then MkDir savePath
        
        TPOReading TPOIter:=TPOIter
        'Stop
        TPOListening TPOIter:=TPOIter
        'Stop
        TPOSpeaking TPOIter:=TPOIter
        'Stop
        TPOWriting TPOIter:=TPOIter
        'Stop
    Next Iter
End Sub

Function GetAnswerText(ByVal str As String)

    If InStr(str, ".") = 0 Then
        str = Split(str, ".")(0)
    Else
        str = Split(str, ".")(1)
    End If
    
    If InStr(str, "¡ð") = 0 Then
        str = Split(str, "¡ð")(0)
    Else
        str = Split(str, "¡ð")(1)
    End If
    
    GetAnswerText = RemovePreceedingWhiteSpace(str)
End Function

Function RemovePreceedingWhiteSpace(ByVal str As String)
    While Left(str, 1) = " "
        str = Right(str, Len(str) - 1)
    Wend
    RemovePreceedingWhiteSpace = str
End Function
'
Function FindQuestion(ByVal editDoc As Document, ByVal myStart As Long, ByVal myEnd As Long, ByVal QuestionIter As String)
    Dim QuestionFind As Find, CharIter As Integer, FirstChar As String
    
    Set QuestionFind = editDoc.Range(myStart, myStart).Find
    
    Do
        CharIter = 0

        Set QuestionFind = editDoc.Range(QuestionFind.Parent.End, myEnd).Find
        QuestionFind.Execute FindText:=QuestionIter & "."
        Do
            CharIter = CharIter + 1
        Loop While Mid(QuestionFind.Parent.Paragraphs(1).Range, CharIter, 1) <> Left(String:=QuestionFind.Parent, Length:=1) And CharIter < 10
        FirstChar = Mid(QuestionFind.Parent.Paragraphs(1).Range, CharIter, 1)
    Loop While FirstChar <> Left(String:=QuestionFind.Parent, Length:=1)
    
    Set FindQuestion = QuestionFind
End Function

Sub AddHeading(ByVal TextString As String, ByRef editDoc As Document, ByVal Position As Long)
    If Position < 1 Then Position = editDoc.content.End
    editDoc.Range(Position - 1, Position).Text = TextString
    editDoc.Range(Position - 1, Position).Paragraphs(1).Range.Bold = True
    editDoc.Range(Position - 1, Position).Paragraphs(1).Range.InsertParagraphAfter
    editDoc.Range(Position - 1, Position).Paragraphs(1).Range.InsertParagraphAfter
    editDoc.Range(Position - 1, Position).InsertParagraphBefore

End Sub

Sub SetFileFormat(ByRef editDoc As Document)
    
    With editDoc.content.Font
        .Size = 11
        .Name = "Calibri"
        .ColorIndex = wdAuto
    End With
    
    With editDoc.Paragraphs
        .LeftIndent = 0
        .RightIndent = 0
        .SpaceBeforeAuto = 0
        .SpaceAfterAuto = 0
        .SpaceBefore = 0
        .SpaceAfter = 0
        .LineUnitBefore = 0
        .LineUnitAfter = 0
        .LineSpacingRule = wdLineSpaceSingle
    End With
    
    editDoc.content.Find.Execute FindText:="¡£", ReplaceWith:=". ", Replace:=wdReplaceAll
    editDoc.content.Find.Execute FindText:="£¬", ReplaceWith:=",", Replace:=wdReplaceAll
    editDoc.content.Find.Execute FindText:="""", ReplaceWith:="""", Replace:=wdReplaceAll
    editDoc.content.Find.Execute FindText:="£¡", ReplaceWith:="!", Replace:=wdReplaceAll
    editDoc.content.Find.Execute FindText:="'", ReplaceWith:="'", Replace:=wdReplaceAll
    editDoc.content.Find.Execute FindText:="£º", ReplaceWith:=":", Replace:=wdReplaceAll

End Sub

Sub AddSpace(ByRef editDoc As Document, ByVal mark As String)
    
    Dim myAnswerFind As Find
    Set myAnswerFind = editDoc.content.Find
    myAnswerFind.Execute FindText:=mark & "[A-Za-z0-9]", MatchWildcards:=True
    While myAnswerFind.Found = True
        myAnswerFind.Parent.Text = Left(myAnswerFind.Parent.Text, 1) & " " & Right(myAnswerFind.Parent.Text, 1)
        Set myAnswerFind = ActiveDocument.content.Find
        myAnswerFind.Execute FindText:=mark & "[A-Za-z0-9]", MatchWildcards:=True
    Wend
End Sub

Sub SetFd(ByVal FileContent As String)
    Dim fName As String, savePath As String
    Dim editDoc As Document
    
    savePath = "C:\Users\decisacter\OneDrive\TOEFL\TPO\TPO " & FileContent & "\"
    fName = Dir(savePath)
    
    While (fName <> "")
        Set editDoc = Documents.Open(FileName:=savePath & fName)
        SetFileFormat editDoc
        editDoc.Close SaveChanges:=True
        fName = Dir
    Wend
End Sub


Private Sub MakeOG()
    Dim Path As String, fd As String, fName As String, FileContent As String
    Dim FdIter As Integer, FIter As Integer
    Dim CpDoc As Document, editDoc As Document
    Dim myFind As Find
    
    For FdIter = 1 To 3
        'Path = "C:\Users\decisacter\OneDrive\TOEFL\TOEFL Official Guide\Practice Test " & FdIter
        FileContent = " Reading"
        
        Set editDoc = Documents.Open(Path & "\OG" & FdIter & FileContent & ".docx")
        editDoc.content.Font.Name = "Calibri"
        editDoc.Close SaveChanges:=True
        
        FileContent = " Listening"
        Set editDoc = Documents.Open(Path & "\OG" & FdIter & FileContent & ".docx")
        editDoc.content.Delete
        For FIter = 1 To 6
            Set CpDoc = Documents.Open(FileName:=Path & "\" & FdIter & "-" & FIter & ".txt")
            Set myFind = CpDoc.content.Find
            myFind.Execute FindText:="#"
            Do
                myFind.Parent.Paragraphs(1).Range.Bold = True
                myFind.Parent.Delete
                Set myFind = CpDoc.Range(myFind.Parent.End, CpDoc.content.End).Find
                myFind.Execute FindText:="#"
            Loop Until Not myFind.Found
            
            Set myFind = CpDoc.content.Find
            myFind.Execute FindText:="Narrator"
            CpDoc.Range(myFind.Parent.Start, CpDoc.content.End).Copy
            editDoc.Range(editDoc.content.End - 1, editDoc.content.End - 1).Paste
            
            editDoc.Range(editDoc.content.End - 1, editDoc.content.End).InsertParagraphAfter
            
            CpDoc.Range(CpDoc.content.Start, myFind.Parent.Start).Copy
            editDoc.Range(editDoc.content.End - 1, editDoc.content.End - 1).Paste
            
            editDoc.Range(editDoc.content.End - 1, editDoc.content.End).InsertParagraphAfter
            editDoc.Range(editDoc.content.End - 1, editDoc.content.End).InsertParagraphAfter
            CpDoc.Close SaveChanges:=False
        Next FIter
        editDoc.content.Font.Name = "Calibri"
        editDoc.Close SaveChanges:=True
        
        FileContent = " Speaking"
        Set editDoc = Documents.Open(Path & "\OG" & FdIter & FileContent & ".docx")
        editDoc.content.Font.Name = "Calibri"
        editDoc.Close SaveChanges:=True
        
        
        FileContent = " Writing"
        
        Set editDoc = Documents.Open(Path & "\OG" & FdIter & FileContent & ".docx")
        
        Set myFind = editDoc.content.Find
        myFind.Execute FindText:="Writing Based on Reading and Listening"
        myFind.Parent.InsertParagraphAfter
        myFind.Parent.InsertParagraphAfter
        myFind.Parent.InsertParagraphAfter
        myFind.Parent.Paragraphs(1).Next(2).Range.Text = "Reading"
        myFind.Parent.Paragraphs(1).Next(2).Range.Bold = True
        
        Set myFind = editDoc.content.Find
        myFind.Execute FindText:="Narrator"
        
        myFind.Parent.InsertParagraphBefore
        myFind.Parent.InsertParagraphBefore
        myFind.Parent.Paragraphs(1).Previous(1).Range.Text = "Listening"
        myFind.Parent.Paragraphs(1).Previous(1).Range.Bold = True
        
        Set myFind = editDoc.content.Find
        myFind.Execute FindText:="Score "
        Do
            
            myFind.Parent.Paragraphs(1).Range.Bold = True
            Set myFind = editDoc.Range(myFind.Parent.End, editDoc.content.End).Find
            myFind.Execute FindText:="Score "
        Loop Until Not myFind.Found
            
        Set myFind = editDoc.content.Find
        myFind.Execute FindText:="Rater"
        Do
            
            myFind.Parent.Paragraphs(1).Range.Bold = True
            Set myFind = editDoc.Range(myFind.Parent.End, editDoc.content.End).Find
            myFind.Execute FindText:="Rater"
        Loop Until Not myFind.Found
        editDoc.content.Font.Name = "Calibri"
        editDoc.Close SaveChanges:=True
        
    Next FdIter
End Sub


'------------------------------------------------------------------------------------
Private Sub MakeSamplerReading()
    Dim FileType As String
    Dim openPath As String, savePath As String, fName As String, questionString As Range
    Dim passageNum As Integer, questionNum As String
    Dim xmlDoc As Document, txtDoc As Document, editDoc As Document
    Dim para As Paragraph
    Dim cpPara As Integer
    
    openPath = "C:\Users\decisacter\Downloads\ETS\TOEFL\TOEFLsampler\forml1\"
    savePath = "C:\Users\decisacter\OneDrive\TOEFL\TOEFLSampleQuestions\Reading\"
    'fd = "TOEFLsampler\"
    fName = Dir(openPath & "SA01*.xml")
    
    Documents.Add
    Documents.Item(Documents.Count).SaveAs2 FileName:=savePath & "Reading Sample 1.docx"
    Set editDoc = Documents("Reading Sample 1.docx")
    While (fName <> "")
        questionNum = Mid(fName, 7, 2)
        If questionNum = "00" Then
            Set txtDoc = Documents.Open(openPath & Left(fName, 8) & ".txt")
            txtDoc.content.Copy
            editDoc.content.Paste
            
        Else
            Set xmlDoc = Documents.Open(openPath & fName)
            Set txtDoc = Documents.Open(openPath & Left(fName, 8) & ".txt")
            Set questionString = GetNodeContent("Stem", xmlDoc)
            
            If Not IsEmpty(InStr(questionString.Text, "]")) Then
            
            ElseIf Not IsEmpty(InStr(questionString.Text, "|")) Then
                
            End If
            xmlDoc.Close SaveChanges:=False
        End If
        'Set editDoc = Documents.Open(FileName:=savePath & fName)
        txtDoc.Close SaveChanges:=False
        
        fName = Dir
    Wend
    
End Sub

Function GetNodeContent(ByVal nodeName As String, ByVal xmlDoc As Document)
    Dim startFind As Find, endFind As Find
    xmlDoc.Activate
    Set startFind = ActiveDocument.content.Find
    Set endFind = ActiveDocument.content.Find
    startFind.Execute FindText:="<" & nodeName & ">"
    endFind.Execute FindText:="</" & nodeName & ">"
    Set GetNodeContent = xmlDoc.Range(startFind.Parent.End, endFind.Parent.Start)
End Function

Sub Temp()
    Dim openPath As String, fName As String
    Dim CpDoc As Document, editDoc As Document
    Dim PassageIter As Integer
    openPath = Environ("HOMEDRIVE") & Environ("HOMEPATH") & "\Downloads\TOEFL\"
    fName = Dir(openPath)
    
    While (fName <> "")
        Set CpDoc = Documents.Open(FileName:=openPath & fName)
        
        'MakeReadingFile CpDoc
        SetFileFormat CpDoc
        fName = Dir
    Wend
    SetFileFormat editDoc
End Sub
