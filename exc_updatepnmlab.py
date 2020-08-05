#!/usr/bin/python3
#import pymongo
from multiprocessing import Pool
import requests
import json
import base64
import hashlib
import datetime
import time
import os
from configparser import ConfigParser
from requests import ReadTimeout
from requests.exceptions import ConnectionError

nodelist=[]

def readKlconf():
    cf = ConfigParser()
    cf.read("kl.conf")
    s = cf.sections()
    global loop,host_status,gpu_status,nvlink_status,disk_status
    loop = int(cf.get("ini", "loop"))
    host_status = int(cf.get("ini", "host_status"))
    gpu_status = int(cf.get("ini", "gpu_status"))
    nvlink_status = int(cf.get("ini", "nvlink_status"))
    disk_status = int(cf.get("ini", "disk_status"))
    #print(s)
    #print(cf.options("nodes"))

def readNodeList():
    global nodelist
    f = open("nodet7.list")
    for i in f:
        nodelist.append(i.strip())
    #print(nodelist)

def updateDatetime():
    os.system('ntpdate cn.pool.ntp.org')
    os.system('date')

def updateMynodes(list):
    for url in list:
        r = requests.get(url)
        aa=json.dumps(r.json())
        jr = json.loads(aa)
        for n in jr:
            exc_updatesh(url,n)
            #mynodes.update({'_id': n['_id']}, {'$setOnInsert': n}, upsert=True)
            #mynodes.update({'_id':n['_id']},{'$set':n},upsert=True)
    #for x in mynodes.find():
        #print(x)

def updateMynodes_pnmlab(list):
    for url in list:
        url1 = "http://"+url+"/?C=updatepnmlab::MS40"
        try:
            r = requests.get(url1,timeout=30)
            r.raise_for_status()  # 如果响应状态码不是 200，就主动抛出异常
        except requests.RequestException as e:
            print(e)
        else:
            result = r.text
            print(type(result), result, sep='\n')
            #mynodes.update({'_id': n['_id']}, {'$setOnInsert': n}, upsert=True)
            #mynodes.update({'_id':n['_id']},{'$set':n},upsert=True)
    #for x in mynodes.find():
        #print(x)
def exc_updatesh(url,n):
    url1 = url.replace("server_node_id_list.php","pserver_node.php")
    print(n['ID'])
    data = {"ID":n['ID'],"ACTION":"updatesh"}
    res = requests.post(url=url1,data=data)
    print(res.text)

def exc_updatepnmlab(url,n):
    #url1 = url.replace("server_node_id_list.php","pserver_node.php")
    url1 = "http://"+n['IP']+"/?C=updatepnmlab::MS40"
    print(n['ID'])
    #data = {"ID":n['ID'],"ACTION":"updatesh"}
    res = requests.get(url=url1)
    print(res.text)

def main(): # 创建一个可以容纳5个进程的进程池
    readNodeList()
    #updateDatetime()
    updateMynodes_pnmlab(nodelist)
    
        

        #print(base64.b64decode(x['status']).decode("GB2312"))
    #ps=Pool(5)
    #for page in range(10):
        #ps.apply(worker,args=(i,)) # 同步执行
        #ps.apply_async(maoyan_spider,args=(page,)) # 异步执行 # 关闭进程池，停止接受其它进程
    #ps.close() # 阻塞进程
    #ps.join()

if __name__ == '__main__': main()
