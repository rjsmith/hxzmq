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

#include <signal.h>
#include <hx/CFFI.h>


// Add in functions for handling system interrupts
// See: http://zguide.zeromq.org/page:all#Handling-Interrupt-Signals

static int s_interrupted = 0;
void s_signal_handler (int signal_value)
{
    s_interrupted = 1;
}

value hx_zmq_catch_signals ()
{
#if defined (_WIN32) 
	// Code adapted from: http://suacommunity.com/dictionary/signal-entry.php
	void (*prev_handler) (int);
    prev_handler = signal (SIGINT, s_signal_handler);
    prev_handler = signal (SIGTERM, s_signal_handler);
#else	
    struct sigaction action;
    action.sa_handler = s_signal_handler;
    action.sa_flags = 0;
    sigemptyset (&action.sa_mask);
    sigaction (SIGINT, &action, NULL);
    sigaction (SIGTERM, &action, NULL);
#endif	
	return alloc_null();
}
DEFINE_PRIM( hx_zmq_catch_signals, 0);

// Returns 1 if interrupted, else 0
value hx_zmq_interrupted ()
{
	return alloc_int(s_interrupted);
}
DEFINE_PRIM (hx_zmq_interrupted, 0);
