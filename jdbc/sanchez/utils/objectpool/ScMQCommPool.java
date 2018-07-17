/**
 * Revision History:
 * Oct. 22 1999 Jiaq
 * Added closePool to close the pool when the JVM is shut down
 */

package sanchez.utils.objectpool;

import java.util.Enumeration;

import sanchez.ipc.ScMQCommunication;
import com.ibm.mq.MQC;
import com.ibm.mq.MQEnvironment;
import com.ibm.mq.MQException;
import com.ibm.mq.MQQueue;
import com.ibm.mq.MQQueueManager;

public class ScMQCommPool extends ScObjectPool {

    MQQueueManager qMgr;        // Actual MQ connection , one per JVM.
    MQQueue request_queue;
    MQQueue reply_queue;
    String qMgrName;
    String ReplyQueueName;

    public ScMQCommPool(int a_iTransIPPort,
                        String a_sTransIPAddress,
                        String a_sTransQueueManager,
                        String a_sTransRequestQueue,
                        String a_sTransReplyQueue,
                        String a_sTransChannel,
                        String a_sTransUserId,
                        String a_sTransPassword) throws MQException {
        super();
        qMgrName = a_sTransQueueManager;
        ReplyQueueName = a_sTransReplyQueue;
        MQEnvironment.hostname = a_sTransIPAddress;
        MQEnvironment.port = a_iTransIPPort;
        MQEnvironment.channel = a_sTransChannel;
        MQEnvironment.userID = a_sTransUserId;
        MQEnvironment.password = a_sTransPassword;
        // Create QueueManager
        qMgr = new MQQueueManager(a_sTransQueueManager);
        int openOptions = MQC.MQOO_FAIL_IF_QUIESCING | MQC.MQOO_OUTPUT;
        // Create Request Queue
        request_queue = qMgr.accessQueue(a_sTransRequestQueue,
                openOptions,
                null,
                null,
                null);
        openOptions = MQC.MQOO_FAIL_IF_QUIESCING | MQC.MQOO_INPUT_SHARED;
        // Create Reply queue.
        reply_queue = qMgr.accessQueue(a_sTransReplyQueue,
                openOptions,
                null,
                null,
                null);

    }


    public Object create() throws Exception {
        return new ScMQCommunication(reply_queue, request_queue, qMgrName, ReplyQueueName);
    }

    protected void expire(Object o) {
        // Expiry Logic
    }

    public boolean validate(Object o) {
        return true;
    }

    public void closePool()
            throws Exception {
        garbage.destroy();
        int num = unlocked.size() + locked.size();
        if (num == 0) return;
        Enumeration enum1 = unlocked.keys();

        ScMQCommunication mq;

        while (enum1.hasMoreElements()) {
            mq = (ScMQCommunication) enum1.nextElement();
            mq.close();
            unlocked.remove(mq);

        }

        enum1 = locked.keys();
        while (enum1.hasMoreElements()) {
            mq = (ScMQCommunication) enum1.nextElement();
            mq.close();
            locked.remove(mq);

        }


    }
}