Describe 'Assert-MockCalled Scope behavior' {
   
    It 'Calls New-AzureVM at least once in the It block' {
        Mock New-AzureVM { }
        { New-AzureVM }            
        #Assert-MockCalled New-AzureVM 0
        Assert-VerifiableMocks
    }
}
