import UIKit
import XCTest
import RxWebSocket
import Starscream


class Tests: XCTestCase {
  
  var socket: RxWebSocket!
  
  override func setUp() {
    super.setUp()
    
    socket = RxWebSocket(url: NSURL(string: "ws://localhost:9000")!)
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
    
    socket.disconnect()
  }
  
  func testWrite() {
    let writeStringExp = expectationWithDescription("Did write string")
    let writeDataExp = expectationWithDescription("Did write data")
    let writeStringFailExp = expectationWithDescription("Did fail to write string")
    let writeDataFailExp = expectationWithDescription("Did fail to write data")
    
    _ = socket.stream.subscribeNext { [unowned self] event in
      switch event {
      case .Connect:
        do {
          try self.socket.write("foo")
          XCTAssert(true)
          writeStringExp.fulfill()
          
          try self.socket.write(NSData())
          XCTAssert(true)
          writeDataExp.fulfill()
        }
        catch (let error as NSError) {
          XCTFail(error.localizedDescription)
        }
        
        // Disconnected socket
        self.socket.disconnect()
      
        
      case .Disconnect:
        do {
          try self.socket.write("foo")
          XCTFail()
        }
        catch (let error as NSError) {
          XCTAssertEqual(error.code, RxWebSocketError.ErrorCode.NotConnected.rawValue)
        }
        
        writeStringFailExp.fulfill()
        
        do {
          try self.socket.write(NSData())
          XCTFail()
        }
        catch (let error as NSError) {
          XCTAssertEqual(error.code, RxWebSocketError.ErrorCode.NotConnected.rawValue)
        }
        
        writeDataFailExp.fulfill()
        
      default:
        break
      }
    }
    
    waitForExpectationsWithTimeout(5, handler: nil)
  }
  
  // MARK: - Reactive components
  
  func testConnectCycle() {
    let connectExp = expectationWithDescription("Completed connect cycle")
    
    _ = socket.stream.subscribeNext { [unowned self] event in
      switch event {
      case .Connect:
        self.socket.disconnect()
        
      case .Disconnect(_):
        connectExp.fulfill()
        
      default:
        break
      }
    }
    
    
    waitForExpectationsWithTimeout(5, handler: nil)
  }
  
  func testReceiveMessage() {
    let messageString = "messageString"
    let exp = expectationWithDescription("Did receive text message")
    
    _ = socket.stream.subscribeNext { [unowned self] event in
      switch event {
      case .Connect:
        _ = try? self.socket.write(messageString)
        
      case .Text(let string):
        XCTAssertEqual(string, messageString)
        exp.fulfill()
        
      default:
        break
      }
    }
    
    waitForExpectationsWithTimeout(5, handler: nil)
  }
  
  func testReceiveData() {
    let messageData = "messageString".dataUsingEncoding(NSUTF8StringEncoding)!
    let exp = expectationWithDescription("Did receive data message")
    
    _ = socket.stream.subscribeNext { [unowned self] event in
      switch event {
      case .Connect:
        _ = try? self.socket.write(messageData)
        
      case .Data(let data):
        XCTAssertEqual(data, messageData)
        exp.fulfill()
        
      default:
        break
      }
    }
    
    waitForExpectationsWithTimeout(5, handler: nil)
  }
  
  func testReceivePong() {
    let exp = expectationWithDescription("Did receive pong")
    
    _ = socket.stream.subscribeNext { [unowned self] event in
      switch event {
      case .Connect:
        _ = try? self.socket.ping()
        
      case .Pong:
        XCTAssert(true)
        exp.fulfill()
        
      default:
        break
      }
    }
    
    waitForExpectationsWithTimeout(5, handler: nil)
  }
  
  // MARK: - Testing Properties
  
  func testProperties_Header() {
    XCTAssertEqual(socket.headers, [:])
    
    let header = ["foo": "bar"]
    socket.headers = header
    XCTAssertEqual(socket.headers, header)
  }
  
  func testProperties_VoipEnabled() {
    XCTAssertFalse(socket.voipEnabled)
    
    let value = true
    socket.voipEnabled = value
    XCTAssertEqual(socket.voipEnabled, value)
  }
  
  func testProperties_SSL() {
    XCTAssertFalse(socket.selfSignedSSL)
    
    let value = true
    socket.selfSignedSSL = value
    XCTAssertEqual(socket.selfSignedSSL, value)
  }
  
  func testProperties_Security() {
    XCTAssertNil(socket.security)
    
    let security = SSLSecurity(usePublicKeys: true)
    socket.security = security
    XCTAssertTrue(socket.security != nil)
  }
  
  func testProperties_SSLSuites() {
    XCTAssertNil(socket.enabledSSLCipherSuites)
    
    let suites = [SSL_NULL_WITH_NULL_NULL]
    socket.enabledSSLCipherSuites = suites
    XCTAssertEqual(socket.enabledSSLCipherSuites!, suites)
  }
}
