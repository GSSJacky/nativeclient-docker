// Include the Geode library.
#include <geode/GeodeCppCache.hpp>
#include <iostream>
#include <string>

// Use the "geode" namespace.
using namespace apache::geode::client;
using namespace std;

// The Hello World example.
int main(int argc, char** argv) {
  try {
    // Create a Geode Cache.
    CacheFactoryPtr cacheFactory = CacheFactory::createCacheFactory();

    CachePtr cachePtr = cacheFactory->create();

    LOGINFO("Hello World");

    RegionFactoryPtr regionFactory =
        cachePtr->createRegionFactory(CACHING_PROXY);

    LOGINFO("Created the RegionFactory");

    // Create the example Region Programmatically.
    RegionPtr regionPtr = regionFactory->create("exampleRegion");

    LOGINFO("Created the Region Programmatically.");
		for( int a = 0; a < 1000; a = a + 1 ) {
			CacheableKeyPtr keyPtr = CacheableString::create("key" + a);
			CacheablePtr valuePtr = CacheableString::create("valuestring,char type" + a);
			regionPtr->put(keyPtr, valuePtr);
    }
    // Put an Entry (Key and Value pair) into the Region using the
    // direct/shortcut method.
    
    LOGINFO("Putting Entries into the Region completed");

    // Put an Entry into the Region by manually creating a Key and a Value pair.
    //CacheableKeyPtr keyPtr = CacheableInt32::create(123);
    //CacheablePtr valuePtr = CacheableString::create("123");
    //regionPtr->put(keyPtr, valuePtr);

    //LOGINFO("Put the second Entry into the Region");


    // Get Entries back out of the Region.
    CacheablePtr result1Ptr = regionPtr->get("key1");

    LOGINFO("Obtained the first Entry from the Region");

    //CacheablePtr result2Ptr = regionPtr->get(keyPtr);

    //LOGINFO("Obtained the second Entry from the Region");

    // Invalidate an Entry in the Region.
    //regionPtr->invalidate("Key1");

    //LOGINFO("Invalidated the first Entry in the Region");

    // Destroy an Entry in the Region.
    //regionPtr->destroy(keyPtr);

    //LOGINFO("Destroyed the second Entry in the Region");

    // Close the Geode Cache.
    cachePtr->close();

    LOGINFO("Closed the Geode Cache");

    return 0;
  }
  // An exception should not occur
  catch (const Exception& geodeExcp) {
    LOGERROR("BasicOperations Geode Exception: %s", geodeExcp.getMessage());

    return 1;
  }
}
