package br.com.hematsu.lance_certo.mapper;

import org.mapstruct.Mapper;

import br.com.hematsu.lance_certo.dto.user.UserRegistrationRequestDTO;
import br.com.hematsu.lance_certo.dto.user.UserResponseDTO;
import br.com.hematsu.lance_certo.model.User;

@Mapper(componentModel = "spring")
public interface UserMapper {

    User userRegistrationRequestDTOToEntity(UserRegistrationRequestDTO dto);

    UserResponseDTO userToUserResponseDTO(User user);

}
