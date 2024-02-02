@IsTest
private class ObjectActionBatchCloneTest {
    @IsTest
    static void testObjectActionBatchClone() {
        Test.startTest();
        ObjectActionBatchClone c = new ObjectActionBatchClone(false);
        Database.executeBatch(c);
        Test.stopTest();
    }
}