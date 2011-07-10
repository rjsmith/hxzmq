/*
    Copyright (c) Richard Smith 2011

    This file is part of hxzmq.

    0MQ is free software; you can redistribute it and/or modify it under
    the terms of the Lesser GNU General Public License as published by
    the Free Software Foundation; either version 3 of the License, or
    (at your option) any later version.

    0MQ is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    Lesser GNU General Public License for more details.

    You should have received a copy of the Lesser GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <assert.h>
#include <zmq.h>
#include <errno.h>

#define IMPLEMENT_API
#include <hx/CFFI.h>

value hx_zmq_version_full()
{
	return alloc_int(ZMQ_VERSION);
}
DEFINE_PRIM( hx_zmq_version_full,0);

value hx_zmq_version_major()
{
	return alloc_int(ZMQ_VERSION_MAJOR);
}
DEFINE_PRIM( hx_zmq_version_major,0);

value hx_zmq_version_minor()
{
	return alloc_int(ZMQ_VERSION_MINOR);
}
DEFINE_PRIM( hx_zmq_version_minor,0);

value hx_zmq_version_patch()
{
	return alloc_int(ZMQ_VERSION_PATCH);
}
DEFINE_PRIM( hx_zmq_version_patch,0);

value hx_zmq_make_version(value major_, value minor_, value patch_)
{
	if ( !val_is_int(major_) || !val_is_int(minor_) || !val_is_int(patch_) )
    	return alloc_null();
  
	return alloc_int(ZMQ_MAKE_VERSION(val_int(major_), val_int(minor_), val_int (patch_)));
}
DEFINE_PRIM( hx_zmq_make_version,3);

value hx_zmq_str_error(value errno_)
{
	if (!val_is_int(errno_))
		return alloc_null();
	
	return alloc_string(strerror(val_int(errno_)));
}
DEFINE_PRIM (hx_zmq_str_error,1);

/* ******* Socket Types ****************/
value hx_zmq_ZMQ_PUB()
{
	return alloc_int(ZMQ_PUB);
}
DEFINE_PRIM( hx_zmq_ZMQ_PUB,0);

value hx_zmq_ZMQ_SUB()
{
	return alloc_int(ZMQ_SUB);
}
DEFINE_PRIM( hx_zmq_ZMQ_SUB,0);

value hx_zmq_ZMQ_PAIR()
{
	return alloc_int(ZMQ_PAIR);
}
DEFINE_PRIM( hx_zmq_ZMQ_PAIR,0);

value hx_zmq_ZMQ_REQ()
{
	return alloc_int(ZMQ_REQ);
}
DEFINE_PRIM( hx_zmq_ZMQ_REQ,0);

value hx_zmq_ZMQ_REP()
{
	return alloc_int(ZMQ_REP);
}
DEFINE_PRIM( hx_zmq_ZMQ_REP,0);

value hx_zmq_ZMQ_ROUTER()
{
	return alloc_int(ZMQ_ROUTER);
}
DEFINE_PRIM( hx_zmq_ZMQ_ROUTER,0);

value hx_zmq_ZMQ_DEALER()
{
	return alloc_int(ZMQ_DEALER);
}
DEFINE_PRIM( hx_zmq_ZMQ_DEALER,0);

value hx_zmq_ZMQ_PULL()
{
	return alloc_int(ZMQ_PULL);
}
DEFINE_PRIM( hx_zmq_ZMQ_PULL,0);

value hx_zmq_ZMQ_PUSH()
{
	return alloc_int(ZMQ_PUSH);
}
DEFINE_PRIM( hx_zmq_ZMQ_PUSH,0);

/* ******* Socket Option Types **********/
value hx_zmq_ZMQ_LINGER()
{
	return alloc_int(ZMQ_LINGER);
}
DEFINE_PRIM( hx_zmq_ZMQ_LINGER,0);

value hx_zmq_ZMQ_HWM()
{
	return alloc_int(ZMQ_HWM);
}

DEFINE_PRIM( hx_zmq_ZMQ_HWM,0);

value hx_zmq_ZMQ_RCVMORE()
{
	return alloc_int(ZMQ_RCVMORE);
}
DEFINE_PRIM( hx_zmq_ZMQ_RCVMORE,0);

value hx_zmq_ZMQ_SUBSCRIBE()
{
	return alloc_int(ZMQ_SUBSCRIBE);
}
DEFINE_PRIM( hx_zmq_ZMQ_SUBSCRIBE,0);

value hx_zmq_ZMQ_UNSUBSCRIBE()
{
	return alloc_int(ZMQ_UNSUBSCRIBE);
}
DEFINE_PRIM( hx_zmq_ZMQ_UNSUBSCRIBE,0);

value hx_zmq_ZMQ_IDENTITY()
{
	return alloc_int(ZMQ_IDENTITY);
}
DEFINE_PRIM( hx_zmq_ZMQ_IDENTITY,0);

value hx_zmq_ZMQ_SWAP()
{
	return alloc_int(ZMQ_SWAP);
}
DEFINE_PRIM( hx_zmq_ZMQ_SWAP,0);

value hx_zmq_ZMQ_AFFINITY()
{
	return alloc_int(ZMQ_AFFINITY);
}
DEFINE_PRIM( hx_zmq_ZMQ_AFFINITY,0);

value hx_zmq_ZMQ_RATE()
{
	return alloc_int(ZMQ_RATE);
}
DEFINE_PRIM( hx_zmq_ZMQ_RATE,0);

value hx_zmq_ZMQ_RECOVERY_IVL()
{
	return alloc_int(ZMQ_RECOVERY_IVL);
}
DEFINE_PRIM( hx_zmq_ZMQ_RECOVERY_IVL,0);

value hx_zmq_ZMQ_RECOVERY_IVL_MSEC()
{
	return alloc_int(ZMQ_RECOVERY_IVL_MSEC);
}
DEFINE_PRIM( hx_zmq_ZMQ_RECOVERY_IVL_MSEC,0);

value hx_zmq_ZMQ_MCAST_LOOP()
{
	return alloc_int(ZMQ_MCAST_LOOP);
}
DEFINE_PRIM( hx_zmq_ZMQ_MCAST_LOOP,0);

value hx_zmq_ZMQ_SNDBUF()
{
	return alloc_int(ZMQ_SNDBUF);
}
DEFINE_PRIM( hx_zmq_ZMQ_SNDBUF,0);

value hx_zmq_ZMQ_RCVBUF()
{
	return alloc_int(ZMQ_RCVBUF);
}
DEFINE_PRIM( hx_zmq_ZMQ_RCVBUF,0);

value hx_zmq_ZMQ_RECONNECT_IVL()
{
	return alloc_int(ZMQ_RECONNECT_IVL);
}
DEFINE_PRIM( hx_zmq_ZMQ_RECONNECT_IVL,0);

value hx_zmq_ZMQ_RECONNECT_IVL_MAX()
{
	return alloc_int(ZMQ_RECONNECT_IVL_MAX);
}
DEFINE_PRIM( hx_zmq_ZMQ_RECONNECT_IVL_MAX,0);

value hx_zmq_ZMQ_BACKLOG()
{
	return alloc_int(ZMQ_BACKLOG);
}
DEFINE_PRIM( hx_zmq_ZMQ_BACKLOG,0);

value hx_zmq_ZMQ_FD()
{
	return alloc_int(ZMQ_FD);
}
DEFINE_PRIM( hx_zmq_ZMQ_FD,0);

value hx_zmq_ZMQ_EVENTS()
{
	return alloc_int(ZMQ_EVENTS);
}
DEFINE_PRIM( hx_zmq_ZMQ_EVENTS,0);

value hx_zmq_ZMQ_TYPE()
{
	return alloc_int(ZMQ_TYPE);
}
DEFINE_PRIM( hx_zmq_ZMQ_TYPE,0);

value hx_zmq_ZMQ_POLLIN()
{
	return alloc_int(ZMQ_POLLIN);
}
DEFINE_PRIM( hx_zmq_ZMQ_POLLIN,0);

value hx_zmq_ZMQ_POLLOUT()
{
	return alloc_int(ZMQ_POLLOUT);
}
DEFINE_PRIM( hx_zmq_ZMQ_POLLOUT,0);

value hx_zmq_ZMQ_POLLERR()
{
	return alloc_int(ZMQ_POLLERR);
}
DEFINE_PRIM( hx_zmq_ZMQ_POLLERR,0);

/* ******* Send/Receive Options ********/
value hx_zmq_DONTWAIT()
{
#ifndef ZMQ_DONTWAIT
	return alloc_int(ZMQ_NOBLOCK);
#else
	return alloc_int(ZMQ_DONTWAIT);
#endif	
}
DEFINE_PRIM( hx_zmq_DONTWAIT,0);

value hx_zmq_SNDMORE()
{
	return alloc_int(ZMQ_SNDMORE);
}
DEFINE_PRIM( hx_zmq_SNDMORE,0);

/* ******* Exception Codes *************/
value hx_zmq_EINVAL()
{
	return alloc_int(EINVAL);
}
DEFINE_PRIM( hx_zmq_EINVAL,0);

value hx_zmq_ENOTSUP()
{
	return alloc_int(ENOTSUP);
}
DEFINE_PRIM( hx_zmq_ENOTSUP,0);

value hx_zmq_EPROTONOSUPPORT()
{
	return alloc_int(EPROTONOSUPPORT);
}
DEFINE_PRIM( hx_zmq_EPROTONOSUPPORT,0);

value hx_zmq_EAGAIN()
{
	return alloc_int(EAGAIN);
}
DEFINE_PRIM( hx_zmq_EAGAIN,0);

value hx_zmq_EFAULT()
{
	return alloc_int(EFAULT);
}
DEFINE_PRIM( hx_zmq_EFAULT,0);

value hx_zmq_ENOMEM()
{
	return alloc_int(ENOMEM);
}
DEFINE_PRIM( hx_zmq_ENOMEM,0);

value hx_zmq_ENODEV()
{
	return alloc_int(ENODEV);
}
DEFINE_PRIM( hx_zmq_ENODEV,0);

value hx_zmq_ENOBUFS()
{
	return alloc_int(ENOBUFS);
}
DEFINE_PRIM( hx_zmq_ENOBUFS,0);

value hx_zmq_ENETDOWN()
{
	return alloc_int(ENETDOWN);
}
DEFINE_PRIM( hx_zmq_ENETDOWN,0);

value hx_zmq_EADDRINUSE()
{
	return alloc_int(EADDRINUSE);
}
DEFINE_PRIM( hx_zmq_EADDRINUSE,0);

value hx_zmq_EADDRNOTAVAIL()
{
	return alloc_int(EADDRNOTAVAIL);
}
DEFINE_PRIM( hx_zmq_EADDRNOTAVAIL,0);

value hx_zmq_ECONNREFUSED()
{
	return alloc_int(ECONNREFUSED);
}
DEFINE_PRIM( hx_zmq_ECONNREFUSED,0);

value hx_zmq_EINPROGRESS()
{
	return alloc_int(EINPROGRESS);
}
DEFINE_PRIM( hx_zmq_EINPROGRESS,0);

value hx_zmq_EMTHREAD()
{
	return alloc_int(EMTHREAD);
}
DEFINE_PRIM( hx_zmq_EMTHREAD,0);

value hx_zmq_EFSM()
{
	return alloc_int(EFSM);
}
DEFINE_PRIM( hx_zmq_EFSM,0);

value hx_zmq_ENOCOMPATPROTO()
{
	return alloc_int(ENOCOMPATPROTO);
}
DEFINE_PRIM( hx_zmq_ENOCOMPATPROTO,0);

value hx_zmq_ETERM()
{
	return alloc_int(ETERM);
}
DEFINE_PRIM( hx_zmq_ETERM,0);

/* ******* ZMQ Devices *************/
value hx_zmq_ZMQ_QUEUE()
{
	return alloc_int(ZMQ_QUEUE);
}
DEFINE_PRIM( hx_zmq_ZMQ_QUEUE, 0);
value hx_zmq_ZMQ_FORWARDER()
{
	return alloc_int(ZMQ_FORWARDER);
}
DEFINE_PRIM( hx_zmq_ZMQ_FORWARDER, 0);
value hx_zmq_ZMQ_STREAMER()
{
	return alloc_int(ZMQ_STREAMER);
}
DEFINE_PRIM( hx_zmq_ZMQ_STREAMER, 0);

