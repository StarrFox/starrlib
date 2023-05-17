import io
import struct
import typing

from typing import Protocol, Self


cpp_type_format_dict = {
    "char": "<c",
    "signed char": "<b",
    "unsigned char": "<B",
    "bool": "?",
    "short": "<h",
    "unsigned short": "<H",
    "int": "<i",
    "unsigned int": "<I",
    "long": "<l",
    "unsigned long": "<L",
    "long long": "<q",
    "unsigned long long": "<Q",
    "float": "<f",
    "double": "<d",
}

rust_type_format_dict = {
    "char": "<c",
    "i8": "<b",
    "u8": "<B",
    "bool": "?",
    "i16": "<h",
    "u16": "<H",
    "i32": "<i",
    "u32": "<I",
    "i64": "<q",
    "u64": "<Q",
    "float": "<f",
    "double": "<d",
}

revolution_type_format_dict = {
    "char": "<c",
    "s1": "<b",
    "s2": "<B",
    "bool": "?",
    "s2": "<h",
    "u2": "<H",
    "s4": "<i",
    "u4": "<I",
    "s8": "<q",
    "u8": "<Q",
    "float": "<f",
    "double": "<d",
}


class TypedBytes:
    def __init__(
        self,
        buffer: io.IOBase,
        *,
        format_dict: dict[str, str] = revolution_type_format_dict,
    ):
        self.buffer = buffer
        self.format_dict = format_dict

    def read_typed(self, type_name: str):
        type_format = self.format_dict[type_name]
        size = struct.calcsize(type_format)
        data = self.buffer.read(size)
        return struct.unpack(type_format, data)[0]

    def write_typed(self, type_name: str, data) -> int:
        type_format = self.format_dict[type_name]
        packed = struct.pack(type_format, data)
        return self.buffer.write(packed)

    def read_string(self, encoding: str = "utf-8") -> str:
        string_len = self.read_typed("unsigned short")
        string_data = self.buffer.read(string_len)
        return string_data.decode(encoding=encoding)

    def write_string(self, string: str, encoding: str = "utf-8"):
        string_len = len(string)
        string_data = string.encode(encoding=encoding)
        self.write_typed("unsigned short", string_len)
        self.buffer.write(string_data)

    def seek_forward_typed(self, type_name: str):
        at = self.buffer.tell()
        size = struct.calcsize(self.format_dict[type_name])
        self.buffer.seek(at + size)

    def seek_back_typed(self, type_name: str):
        at = self.buffer.tell()
        size = struct.calcsize(self.format_dict[type_name])
        self.buffer.seek(at - size)
