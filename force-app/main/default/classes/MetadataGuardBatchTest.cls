@IsTest
private class MetadataGuardBatchTest {
    @IsTest
    static void testMetadataGuardBatchTest() {
        Test.startTest();
        MetadataGuardBatch metaGuardObject = new MetadataGuardBatch(false);
        Database.executeBatch(metaGuardObject);
        Test.stopTest();
    }
}