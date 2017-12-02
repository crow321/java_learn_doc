package cn.qtec.qkcl.auth.client.jni;

import cn.qtec.qkcl.auth.client.entity.q_shield.QShieldInfo;

/**
 * Created by zhangp on 2017/10/16.
 */
public class QKeyService {

    static {
        //加载动态链接库
        System.loadLibrary("QKeyService");
    }

    public static void main(String[] args) {

    }

    /**
     * 调用 Q盾初始化接口 InitQuantumKeys
     * 功能：初始化Q盾，向Q盾中写入三个量子密钥。本接口只有在Q盾的安全模式下才能执行成功
     *
     * @param rootKey          根密钥
     * @param rootKeyLength    根密钥字节长度  1字节
     * @param quantumKey       客户端的量子认证密钥
     * @param quantumKeyLength 客户端的量子认证密钥字节长度  1字节
     * @return                 成功 true, 失败 false
     */
    public native boolean initQuantumKeys(byte[] rootKey, byte rootKeyLength, byte[] quantumKey, byte quantumKeyLength);

    /**
     * Q盾获取启动认证信息接口 GenStartInfo
     * 功能：用于生成客户端的认证信息
     *
     * @return QShieldInfo, 包含信息如下：
     *                      1) deviceID Q盾设备标志
     *                      2) startAuthInfo 客户端开始接入认证信息
     */
    public native QShieldInfo genStartInfo();

    /**
     * Q盾生成认证信息接口 GenAuthInfo
     * 功能：用于生成客户端的认证信息
     *
     * @param inChallengeInfo       服务端返回的挑战报文信息
     * @param inChallengeInfoLength 服务端返回的挑战报文信息字节长度  1字节
     * @return                      用于客户端的接收认证信息
     */
    public native byte[] genAuthInfo(byte[] inChallengeInfo, byte inChallengeInfoLength);

    /**
     * 调用Q盾验证认证信息接口 CheckAuthInfo
     * 功能：用于生成客户端的认证信息
     *
     * @param inAuthInfo       认证信息，由服务器端通过挑战报文带回
     * @param inAuthInfoLength 认证信息字节长度  1字节
     * @return QShieldInfo, 包含信息如下：
     *                      1) 会话密钥ID   sessionKeyID    16字节
     *                      2) 会话密钥Value sessionKey     32字节
     */
    public native QShieldInfo checkAuthInfo(byte[] inAuthInfo, byte inAuthInfoLength);

    /**
     * Q盾加密数据接口（保留接口）EncryptQuantumKeys
     * 功能：用于加密输入的数据
     *
     * @param inputData       输入的数据
     * @param inputDataLength 输入的数据字节长度  4字节
     * @return                加密后的数据
     */
    public native byte[] encryptQuantumKeys(byte[] inputData, int inputDataLength);

    /**
     * Q盾解密数据接口（仅用于处理应用密钥响应报文，报文体中加密内容）：DecryptQuantumKeys
     * 功能：用于解密输入的数据
     *
     * @param inEncryptedData        输入的加密数据
     * @param inEncryptedDataLength  输入的加密数据字节长度  4字节
     * @return                       解密密钥信息，排列方式为KeyID+Key,KeyID+Key…(由外部解密)
     */
    public native byte[] decryptQuantumKeys(byte[] inEncryptedData, int inEncryptedDataLength);

    /**
     * Q盾更新RootKey接口：UpdateRootKey
     * 功能：用于更新RootKey，但是只有在调用更新确认接口之后才能真正更新Q盾中的 RootKey
     *
     * @return 更新后的 rootKey
     */
    public native byte[] updateRootKey();

    /**
     * Q盾RootKey更新确认接口：ConfirmRootKey
     * 功能：用于加密输入的数据
     *
     * @param rootKey       要确认的 RootKey
     * @param rootKeyLength RootKey字节长度 1字节
     * @return              成功 true, 失败 false
     */
    public native boolean confirmRootKey(byte[] rootKey, byte rootKeyLength);
}
