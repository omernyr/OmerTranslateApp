import UIKit
import MessageKit


public struct Message: MessageType {
    public var sender: MessageKit.SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
}

public struct Sender: SenderType {
    public let senderId: String
    public let displayName: String
}

class NewViewController: MessagesViewController, MessagesLayoutDelegate {
    
    let sender = Sender(senderId: "any_unique_id", displayName: "Steven")
    let sender2 = Sender(senderId: "any_unique_id2", displayName: "Ali")
    
    var messages: [MessageType] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messages.append(Message(sender: sender, messageId: "1", sentDate: Date(), kind: .text("How are you?")))
        messages.append(Message(sender: sender2, messageId: "2", sentDate: Date(), kind: .text("Noldu?")))
        messages.append(Message(sender: sender, messageId: "3", sentDate: Date(), kind: .text("Nasılsın")))
        messages.append(Message(sender: sender2, messageId: "4", sentDate: Date(), kind: .text("İyiyim sen")))
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        messagesCollectionView.reloadData()
    }
}

extension NewViewController: MessagesDataSource {
    var currentSender: SenderType {
        return sender
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
}

extension NewViewController: MessagesDisplayDelegate {
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        if message.sender.senderId == sender2.senderId {
            return UIColor(hexString: "FF865E")
        } else {
            return UIColor(hexString: "9685FF")
        }
    }
    
    
}


